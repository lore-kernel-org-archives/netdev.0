From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH net-next-2.6 0/2] Enable UFO on virtio-net/tap devices
Date: Tue, 14 Jul 2009 17:20:58 -0700
Message-ID: <1247617258.4998.75.camel@IBM-19B5263ED41-009047018100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Rusty Russell <rusty@rustcorp.com.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:53286 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755196AbZGOAVB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jul 2009 20:21:01 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e7.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n6F07lc8015019
	for <netdev@vger.kernel.org>; Tue, 14 Jul 2009 20:07:47 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n6F0L06N250688
	for <netdev@vger.kernel.org>; Tue, 14 Jul 2009 20:21:00 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6F0IQPn027197
	for <netdev@vger.kernel.org>; Tue, 14 Jul 2009 20:18:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that the kernel handles sending/receiving of large UDP packets and can do 
software UFO if the outgoing device doesn't support IP fragmentation, we can
enable this feature on virtio-net/tap devices.

[PATCH net-next-2.6 1/2] virtio-net: Allow UFO feature to be set and advertised.
[PATCH net-next-2.6 2/] tun: Allow tap device to send/receive UFO packets.

Thanks
Sridhar


