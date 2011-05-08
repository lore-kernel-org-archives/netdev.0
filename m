From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 7/7] ns: Wire up the setns system call
Date: Sat, 07 May 2011 19:19:37 -0700
Message-ID: <m162pm53ye.fsf@fess.ebiederm.org>
References: <m1tyd7p7tq.fsf@fess.ebiederm.org>
	<1304735101-1824-1-git-send-email-ebiederm@xmission.com>
	<1304735101-1824-7-git-send-email-ebiederm@xmission.com>
	<1304798775.6123.18.camel@mulgrave.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	jamal <hadi@cyberus.ca>, Daniel Lezcano <daniel.lezcano@free.fr>,
	Linux Containers <containers@lists.osdl.org>,
	Renato Westphal <renatowestphal@gmail.com>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1304798775.6123.18.camel@mulgrave.site> (James Bottomley's
	message of "Sat, 07 May 2011 15:06:15 -0500")
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Bottomley <James.Bottomley@HansenPartnership.com> writes:

> On Fri, 2011-05-06 at 19:25 -0700, Eric W. Biederman wrote:
>> v2: Most of the architecture support added by Daniel Lezcano <dlezcano@fr.ibm.com>
>> v3: ported to v2.6.36-rc4 by: Eric W. Biederman <ebiederm@xmission.com>
>> v4: Moved wiring up of the system call to another patch
>> v5: ported to v2.6.39-rc6
>> 
>> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
>
> We already have several syscalls queued up for parisc:
>
> http://git.kernel.org/?p=linux/kernel/git/jejb/parisc-2.6.git;a=shortlog;h=refs/heads/misc
>
> So if you could make this patch over them (or over linux-next), that
> would help the merge process.

I will take a look. I was rather pleasantly surprised that no other
system call conflicts had shown up before now.

This is unfortunately one of those areas where it is almost impossible
to avoid conflicts.

Do you know if there is any chance that the parisc tree might get
rebased or anything horrible like that?

If not I think I will just pull the hunk of the parisc tree with the syscalls
e38f5b745075828ac51b12c8c95c85a7be4a3ec7...2e7bad5f34b5beed47542490c760ed26574e38ba
into my tree so I don't have to worry about merge order.

Eric
