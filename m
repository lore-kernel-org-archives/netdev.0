From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: pmtu discovery on sa esp
Date: Wed, 13 Jun 2007 14:45:26 +0200
Message-ID: <BAY103-DAV16399D5C4B8A85492D8738B2180@phx.gbl>
References: <BAY103-DAV17DFF0DD3E0AEE8CCCB1F3B2190@phx.gbl> <466E92E4.4020008@trash.net>
Cc: <netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc3-s15.bay0.hotmail.com ([65.54.246.215]:23822 "EHLO
	bay0-omc3-s15.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757925AbXFMMpi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 08:45:38 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:

> Marco Berizzi wrote:
> > Hello everybody.
> > I have just upgraded from 2.6.21.3 to
> > 2.6.22-rc4 and I get a ton of
> > pmtu discovery on sa esp/blablab/blabla
> > messages (this box is running openswan).
> > Is this an expected behaviour?
>
>
> We have some MTU opimiztations in 2.6.22-rc that might be related.
> Please check with tcpdump what exactly is happening and whether
> the 2.6.22-rc box is sending too large packets.

Sorry for the late response.
I have done a tcpdump capture on the external
interface but I don't see anything strange.
(I can send to you the capture if you want/need)
I have noticed that the mtu on the aes tunnels
now is equal to 1450 byte (with 2.6.21 it was
1428). Let me explain:

linux 2.6.22-rc4 ->>-AES tunnel ->>- linux 2.6.21 mtu=1450
linux 2.6.21 ->>-AES tunnel ->>- linux 2.6.22-rc4 mtu=1428

Now as a collateral effects all the windoze boxes
aren't able to exchange large packets: I must
upgrade all ipsec gateway to 2.6.22-rc4 (or
downgrade this box to 2.6.21 again). Hints?


