From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Ethernet CRC questions
Date: Wed, 30 Dec 2009 17:29:35 +0100
Message-ID: <1262190575.5685.8.camel@localhost>
References: <f4f837ab0912290917h626bcfecy34fe095a878e733c@mail.gmail.com>
	 <1262108376.5941.5.camel@localhost>
	 <f4f837ab0912292153l7086b631o6e0012d9049eecdb@mail.gmail.com>
	 <1262169433.2247.15.camel@localhost>
	 <f4f837ab0912300819i5fd35ee4o3e0ff4b16362ba0b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas yang <lampsu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:40592 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752394AbZL3Q3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2009 11:29:41 -0500
In-Reply-To: <f4f837ab0912300819i5fd35ee4o3e0ff4b16362ba0b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-12-31 at 00:19 +0800, thomas yang wrote:
> >>
> >> Does the Ethernet frame CRC (generate and verify in hardware)  make
> >> the TX / RX  rate  a little smaller , and a longer end-to-end  delay ?
> >
> > Relative to what?
> >
> 
> Relative to the Ethernet frame without CRC appending / verifying .
> 
> 
> In IEEE 802.3 standard, all network devices should append/verify CRC?

Not 'should' but 'must'.

> >>  Could I disable CRC appending / verifying  in the network card driver
> >>   on all of my nodes (machines) ?
> >
> > Maybe if you want switches to discard everything you send...
> >
> 
> So, I should disable CRC appending / verifying on all kinds of network
> devices in my network?
> In this way I will  TX/RX packets more faster ?

You will probably not be able to disable CRC validation on switches
because it is not a sensible thing to do.  So if you disable CRC
generation on NICs then your network will notwork.

Really, 32 bit-times is not much to worry about (only 320 ns even at
100M).  There are likely to be much bigger sources of latency to attack.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

