From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH 0/2] net: Implement SO_PEERCGROUP and SO_PASSCGROUP socket options
Date: Tue, 22 Apr 2014 13:08:59 -0700
Message-ID: <CALCETrWHA5ZmzOHnz9LO+7v4byc8QiynGyjE_ju5sjokNqrjZA@mail.gmail.com>
References: <1397596546-10153-1-git-send-email-vgoyal@redhat.com> <20140422.160558.627080587952506099.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vivek Goyal <vgoyal@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	cgroups@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>,
	Tejun Heo <tj@kernel.org>, Simo Sorce <ssorce@redhat.com>,
	lpoetter@redhat.com, kay@redhat.com,
	Daniel Walsh <dwalsh@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140422.160558.627080587952506099.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 22, 2014 at 1:05 PM, David Miller <davem@davemloft.net> wrote:
> From: Vivek Goyal <vgoyal@redhat.com>
> Date: Tue, 15 Apr 2014 17:15:44 -0400
>
>> This is another version of patchset to add support passing cgroup
>> information of client over unix socket API.
>
> I'm marking this patch series as "changes requested" in patchwork
> because if we still end up adding this feature SO_PASSCGROUP needs to
> be changed to behave like SO_PASSCRED.
>
> Specifically, like SO_PASSCRED, it should pass the "real" cgroup, ie.
> the cgroup at socket open() time.
>

I suspect that making this change will render it useless,
unfortunately.  I really want to understand the use case.

--Andy
