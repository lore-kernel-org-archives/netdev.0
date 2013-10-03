From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: tx checksum offload in rtl8168evl disabled in driver
Date: Fri, 4 Oct 2013 01:01:20 +0200
Message-ID: <20131003230120.GA25047@electric-eye.fr.zoreil.com>
References: <OF3E5567E2.6AC62D58-ON80257BF9.004ED219-80257BF9.004F713D@aveillant.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hayeswang@realtek.com
To: jason.morgan@aveillant.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:58480 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752477Ab3JCXBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 19:01:31 -0400
Content-Disposition: inline
In-Reply-To: <OF3E5567E2.6AC62D58-ON80257BF9.004ED219-80257BF9.004F713D@aveillant.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jason.morgan@aveillant.com <jason.morgan@aveillant.com> :
[...]
> I'm at 517Mbps and I've found that there seems to be a cpu bottleneck.

Which kernel ?

> I'm using 2k to 4k frames with a rtl8168evl.
> I've found this message
> http://www.spinics.net/lists/netdev/msg216530.html
[...]
> However the message thread, above indicates that this is not a problem and 
> can be changed to make tx-checksum offload possible.
> 
> However we are using a newer chip to the on in the message thread.  I've 
> tried to find other, more recent citations without success.
> 
> So, why is it still turned off ?

It has been disabled since d58d46b5d85139d18eb939aa7279c160bab70484 ("r8169:
jumbo fixes"). Patch was submitted as a RFC on 2011/07/17 and Hayes was
explicitely requested to comment on the jumbo part if necessary. Patch was
submitted for inclusion on 2011/09/22.

Tx checksumming and jumbo are mutually exclusive in Realtek's driver as well.

It seems no recent gigabit chipset reliably supports it.

> What will be the effect of turning it on (changing false to true, in the 
> driver line) for our chip ?

YMMV.

Hayes may elaborate.

-- 
Ueimor
