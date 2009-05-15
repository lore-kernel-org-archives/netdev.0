From: Carsten Aulbert <carsten.aulbert@aei.mpg.de>
Subject: Re: Yukon2 88E8056 card problem with switch?
Date: Fri, 15 May 2009 13:08:45 +0200
Message-ID: <4A0D4D3D.8030902@aei.mpg.de>
References: <4A0BC769.9010507@aei.mpg.de> <20090514080615.6419b121@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from welcomes-you.com ([85.214.50.128]:38494 "EHLO
	smtp.welcomes-you.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752757AbZEOLIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 07:08:50 -0400
In-Reply-To: <20090514080615.6419b121@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi again

Stephen Hemminger schrieb:
> 
> You are only seeing partial flow control. My recommendation would be to
> turn off flow control with:
>    ethtool -A eth0 autoneg off rx off tx off
> 
Tried that, did not help.

> 
> It works with other switches, so check cable and try another switch.
> 

I think I've overlooked something. Is it possible that said chip (or the
driver) has problems with Jumbo frames? Our usual setup for more than a
year now is that we run everything with MTU 9000 and thus I have not
looked into this before. I just did a full install with MTU 1500 and it
just worked.

Is there a known issue with Jumbo frames?

The same set-up (switch, cable, etc, works with an e1000 and Jumbo frames).

Cheers

CArsten

