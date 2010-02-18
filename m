From: Brandon Philips <brandon@ifup.org>
Subject: Re: [PATCH RFC] r8169: straighten out overlength frame detection
 (v3)
Date: Thu, 18 Feb 2010 11:37:33 -0800
Message-ID: <20100218193733.GA23337@jenkins.home.ifup.org>
References: <20100108.160252.189352309.davem@davemloft.net>
 <1263088638.2480.210.camel@localhost>
 <20100110235017.GA8959@electric-eye.fr.zoreil.com>
 <20100110.224504.247142858.davem@davemloft.net>
 <20100112001646.GA7017@electric-eye.fr.zoreil.com>
 <20100130215026.GA6146@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>, ben@decadent.org.uk,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f180.google.com ([209.85.210.180]:42315 "EHLO
	mail-yx0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754271Ab0BRThr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 14:37:47 -0500
Received: by yxe10 with SMTP id 10so1428431yxe.33
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2010 11:37:47 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100130215026.GA6146@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16:50 Sat 30 Jan 2010, Neil Horman wrote:
> On Tue, Jan 12, 2010 at 01:16:46AM +0100, Francois Romieu wrote:
> > On Sun, Jan 10, 2010 at 10:45:04PM -0800, David Miller wrote:
> > [...]
> > > In my opinion if you reset, you give them more power.
> > > 
> > > Instead of just dropping the next few frames, you allow them
> > > to cause a drop of how ever many RX frames can arrive during
> > > the reset period _PLUS_ the amount of other RX frames which
> > > were in the receive ring at the point of detection.
> > 
> > Sure.
> > 
> > The fragmented frame test has been moved a few lines up, before checking
> > for the status bits. Exceedingly small frames are detected and dropped
> > as well.
> > 
> > I have spent the evening disrupting the communication. As a challenger
> > one does not even need complete control : send a few random packets and
> > the card goes to neverland. :o/
> > 
> > I'll do some tests limiting the crap at the first packet.
> > 
> Any further results you can share with us Francois?

Can I offer any help? I found that I have access to a Rev 0x10 card.

Cheers,

	Brandon
