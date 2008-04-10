From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Add Fixed PHY support for ucc_geth
Date: Thu, 10 Apr 2008 19:00:04 -0400
Message-ID: <47FE9BF4.5040400@garzik.org>
References: <>	 <1205833615-15833-1-git-send-email-Joakim.Tjernlund@transmode.se>	 <989B956029373F45A0B8AF029708189001D1954D@zch01exm26.fsl.freescale.net>	 <1207138552.9675.61.camel@gentoo-jocke.transmode.se> <1207868083.9544.10.camel@gentoo-jocke.transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: joakim.tjernlund@transmode.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38728 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757656AbYDJXAQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2008 19:00:16 -0400
In-Reply-To: <1207868083.9544.10.camel@gentoo-jocke.transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joakim Tjernlund wrote:
> On Wed, 2008-04-02 at 14:15 +0200, Joakim Tjernlund wrote:
>> On Fri, 2008-03-21 at 16:51 +0800, Li Yang wrote:
>>>> -----Original Message-----
>>>> From: Joakim Tjernlund [mailto:Joakim.Tjernlund@transmode.se] 
>>>> Sent: Tuesday, March 18, 2008 5:47 PM
>>>> To: Netdev; Li Yang; Linuxppc-Embedded@Ozlabs.Org
>>>> Cc: Joakim Tjernlund
>>>> Subject: [PATCH] Add Fixed PHY support for ucc_geth
>>>>
>>>> The new Fixed PHY method, fixed-link property, isn't
>>>> impl. for ucc_geth which makes fixed PHYs non functional.
>>>> Add support for the new method to restore the Fixed PHY
>>>> functionality.
>>>>
>>>> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
>>> Signed-off-by: Li Yang <leoli@freescale.com>
>>>
>>> ---
>>> Ps: This patch depends on the patch "ucc_geth: use correct thread number
>>> for 10/100Mbps link" to apply, which hasn't made to Linus' tree for now
>>> but has already been in Jeff and David's trees.
>> What happened to this patch? It is not in Linus tree.
>>
>>  Jocke
> 
> David,
> 
> Perhaps you can look into this patch? It has been signedoffed by its
> maintainer and Jeff hasn't commented or applied it.
> 
>  Jocke
> 
>>From 9851f2cffb2eaa3f3dfa02c07d01a93b1a260d78 Mon Sep 17 00:00:00 2001
> From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> Date: Tue, 18 Mar 2008 10:33:43 +0100
> Subject: [PATCH] Add Fixed PHY support for ucc_geth
> 
> The new Fixed PHY method, fixed-link property, isn't
> impl. for ucc_geth which makes fixed PHYs non functional.
> Add support for the new method to restore the Fixed PHY
> functionality.
> 
> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> ---
> 
> This is a regression as fixed PHYs works in 2.6.23 and I am
> using it.
> 
>  drivers/net/ucc_geth.c |   53 +++++++++++++++++++++++++++--------------------
>  1 files changed, 30 insertions(+), 23 deletions(-)

I missed the maintainer signoff, sorry.  That's what I was waiting for.

Queued...

	Jeff




