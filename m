From: "Liran Liss" <liranl@mellanox.co.il>
Subject: RE: [PATCH 03/25] mlx4_core: add multi-functioncommunicationchannel
Date: Thu, 5 Nov 2009 20:16:07 +0200
Message-ID: <2ED289D4E09FBD4D92D911E869B97FDD0166CE74@mtlexch01.mtl.com>
References: <4AF19E14.5070107@mellanox.co.il> <adaiqdq17zo.fsf@cisco.com><2ED289D4E09FBD4D92D911E869B97FDD0166C9B7@mtlexch01.mtl.com> <adatyx8c0lu.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "Yevgeny Petrilin" <yevgenyp@mellanox.co.il>,
	<linux-rdma@vger.kernel.org>, <netdev@vger.kernel.org>,
	"Tziporet Koren" <tziporet@mellanox.co.il>
To: "Roland Dreier" <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:56903 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758013AbZKESNw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 13:13:52 -0500
Content-class: urn:content-classes:message
In-reply-to: <adatyx8c0lu.fsf@roland-alpha.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Right - will fix.
10x,
--Liran


-----Original Message-----
From: Roland Dreier [mailto:rdreier@cisco.com] 
Sent: Thursday, November 05, 2009 8:01 PM
To: Liran Liss
Cc: Yevgeny Petrilin; linux-rdma@vger.kernel.org;
netdev@vger.kernel.org; Tziporet Koren
Subject: Re: [PATCH 03/25] mlx4_core: add
multi-functioncommunicationchannel


 > > And HZ/1000 is going to be 0 if HZ is less than 1000 ... so this is
just  > > going to run continuously in the polling case.

 > This is what we want as long as there are more pending commands.

So then instead of HZ/1000 just use 0 always?  I don't see a reason why
you would want to wait if HZ >= 1000 and not wait if HZ is < 1000.

 - R.
