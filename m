From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Do I need to skb_put() Ethernet frames to a minimum of 60 bytes?
Date: Tue, 14 Aug 2012 21:35:57 +0100
Message-ID: <1344976557.2690.43.camel@bwh-desktop.uk.solarflarecom.com>
References: <502A9EC4.4040208@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: Arvid Brodin <Arvid.Brodin@xdin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:23342 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756255Ab2HNUgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 16:36:00 -0400
In-Reply-To: <502A9EC4.4040208@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-14 at 18:53 +0000, Arvid Brodin wrote:
> Hi,
> 
> If I create an sk_buff with a payload of less than 28 bytes (ethheader + data),
> and send it using the cadence/macb (Ethernet) driver, I get
> 
> eth0: TX underrun, resetting buffers
> 
> Now I know the minimum Ethernet frame size is 64 bytes (including the 4-byte
> FCS), but whose responsibility is it to pad the frame to this size if necessary?
> Mine or the driver's - i.e. should I just skb_put() to the minimum size or
> should I report the underrun as a driver bug?

If the hardware doesn't pad frames automatically then it's the driver's
reponsibility to do so.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
