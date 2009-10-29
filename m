From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Subject: RE: [PATCH v2 4/7] fsl_pq_mdio: Add Suport for etsec2.0 devices.
Date: Thu, 29 Oct 2009 15:41:22 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81B95035E@zin33exm22.fsl.freescale.net>
References: <12566625182528-git-send-email-sandeep.kumar@freescale.com><20091028.024325.134189895.davem@davemloft.net><9F4C7D19E8361D4C94921B95BE08B81B950352@zin33exm22.fsl.freescale.net> <20091029.024546.90958594.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <avorontsov@ru.mvista.com>, "David Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:54624 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753635AbZJ2KLa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 06:11:30 -0400
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id n9TABXaK016073
	for <netdev@vger.kernel.org>; Thu, 29 Oct 2009 03:11:34 -0700 (MST)
Received: from zin33exm22.fsl.freescale.net (zin33exm22.ap.freescale.net [10.232.192.20])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id n9TAF5bR003533
	for <netdev@vger.kernel.org>; Thu, 29 Oct 2009 05:15:07 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <20091029.024546.90958594.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net] 
>Sent: Thursday, October 29, 2009 3:16 PM
>To: Kumar Gopalpet-B05799
>Cc: netdev@vger.kernel.org; avorontsov@ru.mvista.com
>Subject: Re: [PATCH v2 4/7] fsl_pq_mdio: Add Suport for 
>etsec2.0 devices.
>
>From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
>Date: Thu, 29 Oct 2009 15:02:44 +0530
>
>> The absence of the above mentioned commit in the 
>net-next-2.6 tree is 
>> causing some issues with patches getting applied.
>
>You should never use linux-next as you base for working 
>against other people's trees.
>
>Instead, clone net-next-2.6 and work purely against that when 
>sending me patches.

This is the tree I generated the patches against initially. 
The initial set of patches were generated against this tree:
(http://www.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git)

Can you please confirm that the above tree is correct.

After you reported the failure, 
I merged against the linux-next tree, therein I too got a similar
failure.
The reason being the commit from Anton present in linux-next and absent
on net-next.

The patches sent by me applies cleanly to the above mentioned
net-next-2.6 tree. 


--

Thanks
Sandeep
