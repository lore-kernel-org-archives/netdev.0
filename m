From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Rename nsproxy.pid_ns and fix a related security
 bug
Date: Mon, 26 Aug 2013 15:59:09 -0400 (EDT)
Message-ID: <20130826.155909.1859861206590524940.davem@davemloft.net>
References: <cover.1377196394.git.luto@amacapital.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, security@kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: luto@amacapital.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1377196394.git.luto@amacapital.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 22 Aug 2013 11:39:14 -0700

>     commit 92f28d973cce45ef5823209aab3138eb45d8b349
>     Author: Eric W. Biederman <ebiederm@xmission.com>
>     Date:   Fri Mar 15 01:03:33 2013 -0700
> 
>         scm: Require CAP_SYS_ADMIN over the current pidns to spoof pids.
> 
> Eric fell for my bogus claim that nsproxy->pid_ns was the current'
> process's pid ns.  This isn't true.
> 
> Let's fix the bug and rename pid_ns so that no one gets this wrong again.
> 
> Signed-off-by: Andy Lutomirski <luto@amacapital.net>

Eric please take the time to review these changes, thanks.
