From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: correct include file  for restart_syscall
Date: Mon, 13 Dec 2010 02:51:26 -0800
Message-ID: <m14oaivtch.fsf@fess.ebiederm.org>
References: <Pine.LNX.4.64.1012131211001.17382@zuben.voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roland Dreier <rdreier@cisco.com>, <netdev@vger.kernel.org>
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:59064 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751514Ab0LMKve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 05:51:34 -0500
In-Reply-To: <Pine.LNX.4.64.1012131211001.17382@zuben.voltaire.com> (Or
	Gerlitz's message of "Mon, 13 Dec 2010 12:17:16 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz <ogerlitz@voltaire.com> writes:

> Hi,
>
> commit 26574401fef6766f6c3ca25b5c13febe662d2a32 "net: Fix ipoib rtnl_lock
> sysfs deadlock" modified some flows doing rtnl_lock calls to use rtnl_trylock
> / restart_syscall, etc. It turned out that restart_syscall was included in
> ipoib through linux/inet_lro.h which is an include I'd like to remove...
> Is including linux/sched.h being the right thing to do? I wasn't sure as
> this call is very rare, in network drivers its called only by ipoib and
> bonding and it looks like bonding includes it indirectly.

For the definition of restart_syscall yes.

I wish I was clever enough to find a way not to need rtnl_trylock
restart_syscall but unfortunately I don't :(

Eric

