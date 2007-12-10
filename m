From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: routing policy based on u32 classifier
Date: Mon, 10 Dec 2007 16:20:49 +0100
Message-ID: <BAY103-DAV999F982646869B2E4AABAB26B0@phx.gbl>
References: <BAY103-DAV51710C05B584C53DED66DB26B0@phx.gbl> <5A630F46702DD1498FFD48394B4A664C347275DD@john.ad.clarku.edu>
To: "Brian S Julin" <BJulin@clarku.edu>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc2-s11.bay0.hotmail.com ([65.54.246.147]:61984 "EHLO
	bay0-omc2-s11.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751304AbXLJPWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 10:22:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian S Julin wrote:

Marco wrote:

> > Hello everybody.
> > Kindly, I would like to know if the is any plan to add this feature
to a > > future kernel release.
> > I know that fwmark is able to do this, but there is the limitation
in
> > source ip address selection.

> Could you explain the limitation?

Indeed.
Here is an example:

    hdsl|  |adsl
    line|  |line
        |  |
      +------+
      |      |
      |SQUID |
      |      |
      +------+
          |
  internal|
    lan   |


The linux default gateway point to the hdsl
router. I want to redirect the squid http
traffic (running on the same host) to the adsl
line. So I create a routing table (adsl table)
and I put a default route to the adsl router.
I mark the http traffic. I insert a rule
based on fwmark which select the 'adsl table'.
So far, so good. But, squid will select the
source ip address from the hdsl network class,
because it is the default gateway.
Then, the local generated packets must be SNATed
with the adsl ip.
Is it clear?


