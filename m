From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: under-performing bonded interfaces
Date: Thu, 17 Nov 2011 00:57:29 +0000
Message-ID: <1321491449.2709.90.camel@bwh-desktop>
References: <CANj2EbeMRzicixHwrKpCQ3mMqQ1qbyjbRCxpW+CmVRREAhyeRQ@mail.gmail.com>
	 <4EC44ECB.4050201@candelatech.com>
	 <CANj2EbfrtbysEbj+gMa+fOhWo0EWjBXVyGkw8WyiPAV9nPduuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>, <netdev@vger.kernel.org>
To: Simon Chen <simonchennj@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:45056 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754067Ab1KQA5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 19:57:33 -0500
In-Reply-To: <CANj2EbfrtbysEbj+gMa+fOhWo0EWjBXVyGkw8WyiPAV9nPduuQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-11-16 at 19:05 -0500, Simon Chen wrote:
> If used independently, I can get around 9.8Gbps.
[...]
> [   11.572861] ixgbe 0000:03:00.0: (PCI Express:5.0Gb/s:Width x4) e8:9a:8f:23:42:1a
[...]

You need a PCIe 2.0 x8 slot to run 2 10 Gb ports at full speed.  An x4
slot is only good for about 12-13 Gb aggregate throughput (dependent on
packet sizes and other details).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
