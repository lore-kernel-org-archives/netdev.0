From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [PATCH] virtio_net: Give indication on device probe failure.
Date: Thu, 24 Nov 2011 11:24:13 +0200
Message-ID: <1322126653.4248.10.camel@lappy>
References: <20111124082421.26821.71126.sendpatchset@krkumar2.in.ibm.com>
	 <1322123722.4248.4.camel@lappy>
	 <OF0C38CC5A.2D445246-ON65257952.002F945B-65257952.00301BA1@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	rusty@rustcorp.com.au
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:46543 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754045Ab1KXJYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 04:24:17 -0500
Received: by ghrr1 with SMTP id r1so2309218ghr.19
        for <netdev@vger.kernel.org>; Thu, 24 Nov 2011 01:24:17 -0800 (PST)
In-Reply-To: <OF0C38CC5A.2D445246-ON65257952.002F945B-65257952.00301BA1@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-11-24 at 14:17 +0530, Krishna Kumar2 wrote:
> Sasha Levin <levinsasha928@gmail.com> wrote on 11/24/2011 02:05:22 PM:
> 
> > > Provide an indication when the virtio_net device fails to
> > > initialize.
> > >
> > > Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> > > ---
> >
> > [snip]
> >
> > You already get a warning from the thingie that probes PCI:
> >
> > [    1.166311] virtio_net: probe of virtio1 failed with error -12
> 
> Ah, I created this patch based on your feedback:
> 
> > I would suggest adding some output if we take the failure path, since
> > while the guest does boot peacefully, it doesn't have a network
> > interface and there's nothing in the boot log to indicate anything has
> > gone wrong.
> 
> Is this probe error enough to find there was a problem,
> or do you think detailed error in all fail cases is
> required?
> 
> Thanks,
> 
> - KK
> 

Nope, I must have missed that error. Sorry about that.

More warnings there can be useful, but it's true for the probe function
of all other virtio drivers as well :)

-- 

Sasha.
