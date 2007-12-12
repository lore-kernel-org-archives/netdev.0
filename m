From: Dor Laor <dor.laor@gmail.com>
Subject: Re: [kvm-devel] [virtio-net][PATCH] Don't arm tx hrtimer with a constant
 500us each transmit
Date: Wed, 12 Dec 2007 16:17:44 +0200
Message-ID: <475FED88.7020304@qumranet.com>
References: <475FD9E8.1060109@qumranet.com> <200712121419.50400.borntraeger@de.ibm.com>
Reply-To: dor.laor@qumranet.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kvm-devel@lists.sourceforge.net,
	Rusty Russell <rusty@rustcorp.com.au>, netdev@vger.kernel.org,
	virtualization <virtualization@lists.linux-foundation.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:8558 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752472AbXLLORz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 09:17:55 -0500
Received: by ug-out-1314.google.com with SMTP id z38so572412ugc.16
        for <netdev@vger.kernel.org>; Wed, 12 Dec 2007 06:17:48 -0800 (PST)
In-Reply-To: <200712121419.50400.borntraeger@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christian Borntraeger wrote:
>
> Am Mittwoch, 12. Dezember 2007 schrieb Dor Laor:
> > --- a/drivers/net/virtio_net.c
> > +++ b/drivers/net/virtio_net.c
> > @@ -406,10 +405,10 @@ again:
>
> Hmm, while I agree in general with the patch, I fail to find the proper
> version of virtio_net where this patch applies. I tried kvm.git and
> linux-2.6.git from kernel.org. Can you give me a pointer to the repository
> where you work on virtio?
>
Sorry for that, I added some debug prints of my one.
Here it is: *git clone 
git*://kvm.*qumranet*.com/home/*dor*/src/linux-2.6-nv use branch 'virtio'.
BTW: what git repository do you use?

This patch improves my tx performance from 720Mbps to 900Mbps.
Dor
>
> Christian
>

