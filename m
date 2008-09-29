From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCHv2 1/2] [NET] add skb_recycle_check() to enable netdriver skb recycling
Date: Mon, 29 Sep 2008 09:39:31 +0400
Message-ID: <20080929053931.GB21663@2ka.mipt.ru>
References: <20080928204633.GB19070@xi.wantstofly.org> <20080928213824.GA25298@2ka.mipt.ru> <20080928215035.GG19070@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ram.Natarajan@Emulex.Com,
	Eric Dumazet <dada1@cosmosbay.com>,
	Ashish Karkare <akarkare@marvell.com>,
	Nicolas Pitre <nico@cam.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:48103 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754159AbYI2Fl1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2008 01:41:27 -0400
Content-Disposition: inline
In-Reply-To: <20080928215035.GG19070@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Lennert.

On Sun, Sep 28, 2008 at 11:50:35PM +0200, Lennert Buytenhek (buytenh@wantstofly.org) wrote:
> Doesn't it?  It calls skb_release_head_state() (new function), which
> should do that.

Argh, you are right, I missed this hunk:
-/* Free everything but the sk_buff shell. */
-static void skb_release_all(struct sk_buff *skb)
+static void skb_release_head_state(struct sk_buff *skb) 

Patches look good.

-- 
	Evgeniy Polyakov
