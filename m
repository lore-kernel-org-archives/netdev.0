From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [kvm-devel] [virtio-net][PATCH] Don't arm tx hrtimer with a constant 500us each transmit
Date: Wed, 12 Dec 2007 14:19:50 +0100
Message-ID: <200712121419.50400.borntraeger@de.ibm.com>
References: <475FD9E8.1060109@qumranet.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, netdev@vger.kernel.org,
	virtualization <virtualization@lists.linux-foundation.org>
To: kvm-devel@lists.sourceforge.net, dor.laor@qumranet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:55242 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004AbXLLNTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 08:19:54 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.8/8.13.8) with ESMTP id lBCDJskr166434
	for <netdev@vger.kernel.org>; Wed, 12 Dec 2007 13:19:54 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBCDJrMO2887888
	for <netdev@vger.kernel.org>; Wed, 12 Dec 2007 14:19:53 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBCDJqEZ012331
	for <netdev@vger.kernel.org>; Wed, 12 Dec 2007 14:19:53 +0100
In-Reply-To: <475FD9E8.1060109@qumranet.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 12. Dezember 2007 schrieb Dor Laor:
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -406,10 +405,10 @@ again:

Hmm, while I agree in general with the patch, I fail to find the proper 
version of virtio_net where this patch applies. I tried kvm.git and 
linux-2.6.git from kernel.org. Can you give me a pointer to the repository 
where you work on virtio?

Christian
