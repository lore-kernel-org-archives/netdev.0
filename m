From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH RFC] r8169: straighten out overlength frame detection (v3)
Date: Tue, 12 Jan 2010 01:16:46 +0100
Message-ID: <20100112001646.GA7017@electric-eye.fr.zoreil.com>
References: <20100108.160252.189352309.davem@davemloft.net>
 <1263088638.2480.210.camel@localhost>
 <20100110235017.GA8959@electric-eye.fr.zoreil.com>
 <20100110.224504.247142858.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ben@decadent.org.uk, eric.dumazet@gmail.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 49.119.116-78.rev.gaoland.net ([78.116.119.49]:37410 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752365Ab0ALATd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 19:19:33 -0500
Content-Disposition: inline
In-Reply-To: <20100110.224504.247142858.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 10, 2010 at 10:45:04PM -0800, David Miller wrote:
[...]
> In my opinion if you reset, you give them more power.
> 
> Instead of just dropping the next few frames, you allow them
> to cause a drop of how ever many RX frames can arrive during
> the reset period _PLUS_ the amount of other RX frames which
> were in the receive ring at the point of detection.

Sure.

The fragmented frame test has been moved a few lines up, before checking
for the status bits. Exceedingly small frames are detected and dropped
as well.

I have spent the evening disrupting the communication. As a challenger
one does not even need complete control : send a few random packets and
the card goes to neverland. :o/

I'll do some tests limiting the crap at the first packet.

-- 
Ueimor
