From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Subject: RE: [RFC] gianfar: multi queue stuff not complete
Date: Thu, 19 Nov 2009 14:44:51 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81B950E2E@zin33exm22.fsl.freescale.net>
References: <4B05019F.4090208@gmail.com> <9F4C7D19E8361D4C94921B95BE08B81B950E25@zin33exm22.fsl.freescale.net> <4B050C25.5010309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	"Linux Netdev List" <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:40720 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753282AbZKSJOu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 04:14:50 -0500
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id nAJ9Ete2015528
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2009 02:14:55 -0700 (MST)
Received: from zin33exm22.fsl.freescale.net (zin33exm22.ap.freescale.net [10.232.192.20])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id nAJ9JDtg023611
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2009 03:19:15 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <4B050C25.5010309@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
>> Eric, Yes I agree that still there are a couple of changes 
>left and I 
>> am working on it.
>> One of them being the stats. Currently caught up in 
>something else, I 
>> will update them ASAP.
>> 
>> Also, suggest me on what kind of stats do I need to maintain ? Both 
>> per device and per queue or only per queue would be sufficient ?
>> 
>Optimum would be per queue only, to avoid locking and let each 
>queue be really independant.
>

Thanks Eric, I will proceed with per queue stats then.
