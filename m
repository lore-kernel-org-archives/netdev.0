From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Subject: RE: [RFC PATCH] gianfar: update txq->trans_start rather than dev->trans_start
Date: Sat, 26 Dec 2009 11:07:33 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81BA09075@zin33exm22.fsl.freescale.net>
References: <1260972281-20012-1-git-send-email-Sandeep.Kumar@freescale.com> <20091225.184503.28832017.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <avorontsov@ru.mvista.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:33629 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769AbZLZFhi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Dec 2009 00:37:38 -0500
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id nBQ5baoh025886
	for <netdev@vger.kernel.org>; Fri, 25 Dec 2009 22:37:36 -0700 (MST)
Received: from zin33exm22.fsl.freescale.net (zin33exm22.ap.freescale.net [10.232.192.20])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id nBQ5bboS006137
	for <netdev@vger.kernel.org>; Fri, 25 Dec 2009 23:37:38 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <20091225.184503.28832017.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net] 
>Sent: Saturday, December 26, 2009 8:15 AM
>To: Kumar Gopalpet-B05799
>Cc: netdev@vger.kernel.org; avorontsov@ru.mvista.com
>Subject: Re: [RFC PATCH] gianfar: update txq->trans_start 
>rather than dev->trans_start
>
>From: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
>Date: Wed, 16 Dec 2009 19:34:41 +0530
>
>> Signed-off-by: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
>> ---
>> 
>>  *. Please let me know if updating txq->trans_start in gfar_start is
>>     alright, although updating txq->trans_start in gfar_start_xmit( )
>>     should be done.
>
>See commit 08baf561083bc27a953aa087dd8a664bb2b88e8e, you don't 
>have to update *->trans_start at all, the generic code will do 
>it for you.
>

OK. Thanks David. 

>For example, this is why you won't be able to find any 
>trans_start references in drivers such as ixgbe
>
