From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [kvm-devel] [virtio-net][PATCH] Don't arm tx hrtimer with a constant 500us each transmit
Date: Wed, 12 Dec 2007 17:33:07 +0100
Message-ID: <200712121733.07804.borntraeger@de.ibm.com>
References: <475FD9E8.1060109@qumranet.com> <200712121419.50400.borntraeger@de.ibm.com> <475FED88.7020304@qumranet.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: kvm-devel@lists.sourceforge.net,
	Rusty Russell <rusty@rustcorp.com.au>, netdev@vger.kernel.org,
	virtualization <virtualization@lists.linux-foundation.org>
To: dor.laor@qumranet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([195.212.29.140]:41628 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757469AbXLLQdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 11:33:45 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate7.uk.ibm.com (8.13.8/8.13.8) with ESMTP id lBCGXiwm072764
	for <netdev@vger.kernel.org>; Wed, 12 Dec 2007 16:33:44 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBCGXiTL3596346
	for <netdev@vger.kernel.org>; Wed, 12 Dec 2007 16:33:44 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBCGXR2H023949
	for <netdev@vger.kernel.org>; Wed, 12 Dec 2007 16:33:28 GMT
In-Reply-To: <475FED88.7020304@qumranet.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 12. Dezember 2007 schrieb Dor Laor:
> Christian Borntraeger wrote:
> >
> > Am Mittwoch, 12. Dezember 2007 schrieb Dor Laor:
> > > --- a/drivers/net/virtio_net.c
> > > +++ b/drivers/net/virtio_net.c
> > > @@ -406,10 +405,10 @@ again:
> >
> > Hmm, while I agree in general with the patch, I fail to find the proper
> > version of virtio_net where this patch applies. I tried kvm.git and
> > linux-2.6.git from kernel.org. Can you give me a pointer to the 
repository
> > where you work on virtio?
> >
> Sorry for that, I added some debug prints of my one.
> Here it is: *git clone 
> git*://kvm.*qumranet*.com/home/*dor*/src/linux-2.6-nv use branch 'virtio'.

Ah, ok. I will look into that branch.

> BTW: what git repository do you use?

I use Avis git from kernel.org:
git://git.kernel.org/pub/scm/linux/kernel/git/avi/kvm

Christian
