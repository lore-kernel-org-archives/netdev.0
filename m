From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/2] Rename nsproxy.pid_ns and fix a related security bug
Date: Mon, 26 Aug 2013 18:03:57 -0700
Message-ID: <87sixwlzb6.fsf@xmission.com>
References: <cover.1377196394.git.luto@amacapital.net>
	<20130826.155909.1859861206590524940.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: luto@amacapital.net, security@kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130826.155909.1859861206590524940.davem@davemloft.net> (David
	Miller's message of "Mon, 26 Aug 2013 15:59:09 -0400 (EDT)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: Andy Lutomirski <luto@amacapital.net>
> Date: Thu, 22 Aug 2013 11:39:14 -0700
>
>>     commit 92f28d973cce45ef5823209aab3138eb45d8b349
>>     Author: Eric W. Biederman <ebiederm@xmission.com>
>>     Date:   Fri Mar 15 01:03:33 2013 -0700
>> 
>>         scm: Require CAP_SYS_ADMIN over the current pidns to spoof pids.
>> 
>> Eric fell for my bogus claim that nsproxy->pid_ns was the current'
>> process's pid ns.  This isn't true.
>> 
>> Let's fix the bug and rename pid_ns so that no one gets this wrong again.
>> 
>> Signed-off-by: Andy Lutomirski <luto@amacapital.net>
>
> Eric please take the time to review these changes, thanks.

Reviewed they are good.

My apologies for the delay life got in my way and I fell behind on
dealing with patches.

Eric
