From: Divy Le Ray <divy@chelsio.com>
Subject: Re: Hitting slab BUG with bridging/cxgb3 on 2.6.31-rc2
Date: Wed, 08 Jul 2009 18:38:37 -0700
Message-ID: <4A554A1D.3070703@chelsio.com>
References: <adaeisq23rq.fsf@cisco.com> <adaljmyzof4.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:31860 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755331AbZGIBmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 21:42:05 -0400
In-Reply-To: <adaljmyzof4.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roland Dreier wrote:
> 2.6.30 seems OK -- wasn't able to hit this bug.
>
> Commencing the bisection... will take a while, since triggering the bug
> is slow and rebooting this box is slow as well too (since it has a long
> BIOS sequence...)
>   
Hi Roland,

The cxgb3 patch that touches the data path since 2.6.30 is the LLTX removal:
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=c3a8c5b644118b5e2cfd0690b1dcea904a792c52

Would you mind reverting only this change only and see if the bug is 
going away?

Cheers,
Divy
