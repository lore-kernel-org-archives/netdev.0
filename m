From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Commit-8b63ec18 breaks setting PHY pad-skew settings
Date: Tue, 22 Dec 2015 11:18:36 +0100
Message-ID: <20151222101836.GA2373@lunn.ch>
References: <FC629F1A536C6F42B960B5E32E20BD356A967AF0@exc2.buero.ginzinger.com>
 <56785808.6050804@gmail.com>
 <FC629F1A536C6F42B960B5E32E20BD356A969BC7@exc2.buero.ginzinger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Florian Fainelli' <f.fainelli@gmail.com>,
	"david.daney@cavium.com" <david.daney@cavium.com>,
	"buytenh@wantstofly.org" <buytenh@wantstofly.org>,
	"grant.likely@secretlab.ca" <grant.likely@secretlab.ca>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Roosen Henri <Henri.Roosen@ginzinger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47729 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932181AbbLVKSn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Dec 2015 05:18:43 -0500
Content-Disposition: inline
In-Reply-To: <FC629F1A536C6F42B960B5E32E20BD356A969BC7@exc2.buero.ginzinger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Unfortunately the patch is incomplete: it only fixes the issue for
> the KSZ9021. Please have a look at the funcion ksz9031_config_init()
> which has the the same (broken) search for the parent node.

Ah, sorry missed that. I was a bit blinkered, the issue was report for
KSZ9021 and i did not look further.

> As both the code for KSZ9021 as well as the code for KSZ9031 parse
> the same pad skew settings from the OF node (and to prevent
> incomplete fixes in the future), I think this code is a candidate to
> be cleaned up. Or is cooking up a similar patch for the KSZ9031 as
> for the KSZ9021 preferred?

Both would be best. We probably need a minimal fix we can get included
fast, and then having a cleanup patch merged during the next merge
window would be nice.

> Additionally, if this is a deprecated feature (like the commit
> states), then the devicetree binding documentation
> (Documentation/devicetree/bindings/net/micrel-ksz90x1.txt) should be
> updated. At least the deprecated example for autodetected PHY's
> should be corrected/removed.

I submitted a patch for that already.
https://www.mail-archive.com/netdev@vger.kernel.org/msg90932.html

It however does not seem to of made its way into net-next. If you
agree with it, please send an reviewed-by, or an Acked-by...

      Andrew
