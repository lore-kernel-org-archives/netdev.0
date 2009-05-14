From: Carsten Aulbert <carsten.aulbert@aei.mpg.de>
Subject: Re: Yukon2 88E8056 card problem with switch?
Date: Thu, 14 May 2009 17:41:41 +0200
Message-ID: <4A0C3BB5.4080108@aei.mpg.de>
References: <4A0BC769.9010507@aei.mpg.de> <20090514080615.6419b121@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from welcomes-you.com ([85.214.50.128]:51335 "EHLO
	smtp.welcomes-you.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751010AbZENQDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2009 12:03:17 -0400
In-Reply-To: <20090514080615.6419b121@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi (thanks for the quick reply)

Stephen Hemminger schrieb:
> 
> You are only seeing partial flow control. My recommendation would be to
> turn off flow control with:
>    ethtool -A eth0 autoneg off rx off tx off

I've tried that, but that did *not* change the overall behavior -
although I omitted autosense off so far. I'll redo the test.

> 
> It works with other switches, so check cable and try another switch.
> 

I'll check that again, however we are pretty limited to this brand since
we need to have these because of the big uplink capabilities. If I
cannot reproduce this with another switch, I'll start bugging them :)

Cheers

Carsten
