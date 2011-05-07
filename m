From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH 2/7] ns: Introduce the setns syscall
Date: Sun, 08 May 2011 00:39:18 +0200
Message-ID: <4DC5CA16.2070103@free.fr>
References: <m1tyd7p7tq.fsf@fess.ebiederm.org> <1304735101-1824-1-git-send-email-ebiederm@xmission.com> <1304735101-1824-2-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	jamal <hadi@cyberus.ca>,
	Linux Containers <containers@lists.osdl.org>,
	Renato Westphal <renatowestphal@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1304735101-1824-2-git-send-email-ebiederm@xmission.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/07/2011 04:24 AM, Eric W. Biederman wrote:
> With the networking stack today there is demand to handle
> multiple network stacks at a time.  Not in the context
> of containers but in the context of people doing interesting
> things with routing.
>
> There is also demand in the context of containers to have
> an efficient way to execute some code in the container itself.
> If nothing else it is very useful ad a debugging technique.
>
> Both problems can be solved by starting some form of login
> daemon in the namespaces people want access to, or you
> can play games by ptracing a process and getting the
> traced process to do things you want it to do. However
> it turns out that a login daemon or a ptrace puppet
> controller are more code, they are more prone to
> failure, and generally they are less efficient than
> simply changing the namespace of a process to a
> specified one.
>
> Pieces of this puzzle can also be solved by instead of
> coming up with a general purpose system call coming up
> with targed system calls perhaps socketat that solve
> a subset of the larger problem.  Overall that appears
> to be more work for less reward.
>
> int setns(int fd, int nstype);
>
> The fd argument is a file descriptor referring to a proc
> file of the namespace you want to switch the process to.
>
> In the setns system call the nstype is 0 or specifies
> an clone flag of the namespace you intend to change
> to prevent changing a namespace unintentionally.
>
> v2: Most of the architecture support added by Daniel Lezcano<dlezcano@fr.ibm.com>
> v3: ported to v2.6.36-rc4 by: Eric W. Biederman<ebiederm@xmission.com>
> v4: Moved wiring up of the system call to another patch
>
> Signed-off-by: Eric W. Biederman<ebiederm@xmission.com>
> ---

Acked-by: Daniel Lezcano <daniel.lezcano@free.fr>
