From: Ulrich Kunitz <kune@deine-taler.de>
Subject: Re: proposal for new wireless configuration API
Date: Fri, 18 Aug 2006 01:23:56 +0200
Message-ID: <20060817232355.GA23163@p15091797.pureserver.info>
References: <1155799178.3653.4.camel@ux156> <C86180A8C204554D8A3323D8F6B0A29F0165B02D@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:41678 "EHLO
	p15091797.pureserver.info") by vger.kernel.org with ESMTP
	id S965156AbWHQXX5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 19:23:57 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F0165B02D@dhost002-46.dex002.intermedia.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06-08-17 09:42 Simon Barber wrote:

> The spec for RSSI is very loose - RSSI is just a 8 bit unsigned number,
> guaranteed to be a monotonically increasing function of signal strength.
> You don't get to know anything about the scale, or linearity of the
> function. In essence RSSI is a vendor specific value, of no known units.
> Not very useful unless you know some card specific details to help
> interpret it.
> 
> Now some cards return a signal strength in dBm as the RSSI - note that
> this fits the requirements of a RSSI measure just fine. RCPI is simply a
> more tightly specified signal strength measure.
> 
> Just saying that a RSSI value is not very useful.

we are simply not able to deliver RCPI, because we have no idea
how RSSI is measured for the ZD1211 device. We had discussions with the
vendor developers, but it seemed that their understanding was not
really more advanced than our's.

There is the same issue for signal quality and signal-to-noise
ratio.

-- 
Uli Kunitz
