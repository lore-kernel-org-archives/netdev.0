From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: RFC: Audit Kernel Container IDs
Date: Thu, 14 Sep 2017 12:33:06 -0500
Message-ID: <87d16tb2y5.fsf@xmission.com>
References: <20170913171328.GP3405@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain
Cc: cgroups@vger.kernel.org,
        Linux Containers <containers@lists.linux-foundation.org>,
        Linux API <linux-api@vger.kernel.org>,
        Linux Audit <linux-audit@redhat.com>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        Linux Network Development <netdev@vger.kernel.org>,
        Aristeu Rozanski <arozansk@redhat.com>,
        David Howells <dhowells@redhat.com>,
        Eric Paris <eparis@parisplace.org>, jlayton@redhat.com,
        Andy Lutomirski <luto@kernel.org>, mszeredi@redhat.com,
        Paul Moore <pmoore@redhat.com>,
        "Serge E. Hallyn" <serge@hallyn.com>,
        Steve Grubb <sgrubb@redhat.com>, trondmy@primarydata.com,
        Al Viro <viro@zeniv.linux.org.uk>
To: Richard Guy Briggs <rgb@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170913171328.GP3405@madcap2.tricolour.ca> (Richard Guy
        Briggs's message of "Wed, 13 Sep 2017 13:13:28 -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Richard Guy Briggs <rgb@redhat.com> writes:

> The trigger is a pseudo filesystem (proc, since PID tree already exists)
> write of a u64 representing the container ID to a file representing a
> process that will become the first process in a new container.
> This might place restrictions on mount namespaces required to define a
> container, or at least careful checking of namespaces in the kernel to
> verify permissions of the orchestrator so it can't change its own
> container ID.

Why a u64?

Why a proc filesystem write and not a magic audit message?
I don't like the fact that the proc filesystem entry is likely going to
be readable and abusable by non-audit contexts?

Why the ability to change the containerid?  What is the use case you are
thinking of there?

Eric
