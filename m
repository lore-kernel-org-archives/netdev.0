From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH] virtio_net: Give indication on device probe failure.
Date: Thu, 24 Nov 2011 14:17:43 +0530
Message-ID: <OF0C38CC5A.2D445246-ON65257952.002F945B-65257952.00301BA1@in.ibm.com>
References: <20111124082421.26821.71126.sendpatchset@krkumar2.in.ibm.com> <1322123722.4248.4.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	rusty@rustcorp.com.au
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp02.in.ibm.com ([122.248.162.2]:38865 "EHLO
	e28smtp02.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754585Ab1KXJOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 04:14:16 -0500
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <krkumar2@in.ibm.com>;
	Thu, 24 Nov 2011 14:17:17 +0530
Received: from d28av06.in.ibm.com (d28av06.in.ibm.com [9.184.220.48])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAO8jTTq3088396
	for <netdev@vger.kernel.org>; Thu, 24 Nov 2011 14:15:33 +0530
Received: from d28av06.in.ibm.com (loopback [127.0.0.1])
	by d28av06.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAO8jTAJ016628
	for <netdev@vger.kernel.org>; Thu, 24 Nov 2011 14:15:29 +0530
In-Reply-To: <1322123722.4248.4.camel@lappy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sasha Levin <levinsasha928@gmail.com> wrote on 11/24/2011 02:05:22 PM:

> > Provide an indication when the virtio_net device fails to
> > initialize.
> >
> > Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> > ---
>
> [snip]
>
> You already get a warning from the thingie that probes PCI:
>
> [    1.166311] virtio_net: probe of virtio1 failed with error -12

Ah, I created this patch based on your feedback:

> I would suggest adding some output if we take the failure path, since
> while the guest does boot peacefully, it doesn't have a network
> interface and there's nothing in the boot log to indicate anything has
> gone wrong.

Is this probe error enough to find there was a problem,
or do you think detailed error in all fail cases is
required?

Thanks,

- KK
