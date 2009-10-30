From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Subject: RE: [PATCH v3 4/7] fsl_pq_mdio: Add Suport for etsec2.0 devices.
Date: Fri, 30 Oct 2009 14:12:22 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81B9503DF@zin33exm22.fsl.freescale.net>
References: <1256826229-529-1-git-send-email-Sandeep.Kumar@freescale.com><20091029.212142.189578068.davem@davemloft.net><9F4C7D19E8361D4C94921B95BE08B81B9503CA@zin33exm22.fsl.freescale.net> <20091030.005924.56385149.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "Fleming Andy-AFLEMING" <afleming@freescale.com>,
	"David Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:45778 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755263AbZJ3ImV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 04:42:21 -0400
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id n9U8gPL5000801
	for <netdev@vger.kernel.org>; Fri, 30 Oct 2009 01:42:26 -0700 (MST)
Received: from zin33exm22.fsl.freescale.net (zin33exm22.ap.freescale.net [10.232.192.20])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id n9U8jMRe004353
	for <netdev@vger.kernel.org>; Fri, 30 Oct 2009 03:45:23 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <20091030.005924.56385149.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net] 
>Sent: Friday, October 30, 2009 1:29 PM
>To: Kumar Gopalpet-B05799
>Cc: netdev@vger.kernel.org; Fleming Andy-AFLEMING
>Subject: Re: [PATCH v3 4/7] fsl_pq_mdio: Add Suport for 
>etsec2.0 devices.
>
>From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
>Date: Fri, 30 Oct 2009 12:52:29 +0530
>
>> 
>> 1. The patch failure is due to the absence of following commit in
>> net-next-2.6 tree.
>> 	
>> 	commit e72701acbe0b35e52d3f04d442837c06b4e64f1c
>> 	Author: Anton Vorontsov <avorontsov@ru.mvista.com>
>> 	Date:   Wed Oct 14 14:54:52 2009 -0700
>
>It is in the net-next-2.6 tree, something is wrong with your clone.

We were referring to the logs shown on the gitweb.
The tree log does not show this commit. 
(search for this commit id failed)
http://git.kernel.org/?p=linux%2Fkernel%2Fgit%2Fdavem%2Fnet-next-2.6.git
&a=search&h=29906f6a427d2004a515ebbcdc7b28bae8f6c19c&st=commit&s=e72701a
cbe0b35e52d3f04d442837c06b4e64f1c

Whereas, the log for the file does show the commit.
http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=histo
ry;f=drivers/net/fsl_pq_mdio.c;h=6ac4648669728421b934d32646ffbb626128387
6;hb=HEAD

Why is there such a mismatch on the tree itself?

>
>davem@sunset:~/src/GIT/net-next-2.6$ git describe 
>e72701acbe0b35e52d3f04d442837c06b4e64f1c
>v2.6.31-9041-ge72701a
>davem@sunset:~/src/GIT/net-next-2.6$ 

Even we get this on our clone. 
However, the changes to the file itself are absent.

Shall we generate the patch series against the snapshot (which contains
the changes)? 


--

Thanks
Sandeep
