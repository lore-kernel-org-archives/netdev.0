From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v3 03/10] net: Add netdev interfaces recording
 send/compl
Date: Mon, 28 Nov 2011 17:49:51 +0000
Message-ID: <1322502591.26733.8.camel@bwh-desktop>
References: <20111123094614.36560215@nehalam.linuxnetplumber.net>
	 <20111123.185812.1721878183759040757.davem@davemloft.net>
	 <20111123160320.76143e3b@nehalam.linuxnetplumber.net>
	 <20111123.190623.2026426589805797580.davem@davemloft.net>
	 <CA+mtBx-VSJ6U2SyUxQt7eK9+cXFFAEQXgmhc+yWwpTX8zd6TJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <shemminger@vyatta.com>,
	<netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:12697 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753437Ab1K1Rtz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 12:49:55 -0500
In-Reply-To: <CA+mtBx-VSJ6U2SyUxQt7eK9+cXFFAEQXgmhc+yWwpTX8zd6TJA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-11-23 at 16:32 -0800, Tom Herbert wrote:
> >> I was referring to the transmit routine, there for netdev_sent_queue()
> >> is always called with one packet.
> >
> > Optimism for the future? :-)
> >
> 
> Yep, I am looking forward to the day that someone figures out how to
> batch transmits in a meaningful way!
[...]

UFO/TSO do something like that.  Should we count physical or logical
packets?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
