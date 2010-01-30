From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH RFC] r8169: straighten out overlength frame detection (v3)
Date: Sat, 30 Jan 2010 16:50:26 -0500
Message-ID: <20100130215026.GA6146@localhost.localdomain>
References: <20100108.160252.189352309.davem@davemloft.net>
 <1263088638.2480.210.camel@localhost>
 <20100110235017.GA8959@electric-eye.fr.zoreil.com>
 <20100110.224504.247142858.davem@davemloft.net>
 <20100112001646.GA7017@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, ben@decadent.org.uk,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37056 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753014Ab0A3Vuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2010 16:50:51 -0500
Content-Disposition: inline
In-Reply-To: <20100112001646.GA7017@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 12, 2010 at 01:16:46AM +0100, Francois Romieu wrote:
> On Sun, Jan 10, 2010 at 10:45:04PM -0800, David Miller wrote:
> [...]
> > In my opinion if you reset, you give them more power.
> > 
> > Instead of just dropping the next few frames, you allow them
> > to cause a drop of how ever many RX frames can arrive during
> > the reset period _PLUS_ the amount of other RX frames which
> > were in the receive ring at the point of detection.
> 
> Sure.
> 
> The fragmented frame test has been moved a few lines up, before checking
> for the status bits. Exceedingly small frames are detected and dropped
> as well.
> 
> I have spent the evening disrupting the communication. As a challenger
> one does not even need complete control : send a few random packets and
> the card goes to neverland. :o/
> 
> I'll do some tests limiting the crap at the first packet.
> 
Any further results you can share with us Francois?

Thanks
Neil
