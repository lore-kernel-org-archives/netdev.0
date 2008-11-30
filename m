From: Trent Piepho <tpiepho@freescale.com>
Subject: Re: what is the expeted performance from a dual port 10G card ?
Date: Sat, 29 Nov 2008 18:55:50 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0811291853010.12483@t2.domain.actdsltmp>
References: <5d96567b0811280511q1e3f7774j7eabce4810dae91a@mail.gmail.com>
 <20081128135419.GH32518@solarflare.com> <5d96567b0811290010r641388b7w179bc4af26bbf103@mail.gmail.com>
 <20081129173442.GI32518@solarflare.com> <adamyfib173.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ben Hutchings <bhutchings@solarflare.com>, Raz <raziebe@gmail.com>,
	netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:37042 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752848AbYK3C7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Nov 2008 21:59:23 -0500
In-Reply-To: <adamyfib173.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 29 Nov 2008, Roland Dreier wrote:
> > The 8b10 encoding is already accounted for in the 2.5 Gbps figure;
> > the raw bit rate is 3.125 Gbps.
>
> In addition, PCI Express transfers are broken up into packets, usually
> with very small payloads (128 or 256 bytes are common).  So the packet
> header overhead reduces throughput further, and then the transaction
> layer adds further overhead.  Then transferring NIC control structures
> over the link adds even more overhead.  So achieving 13.something Gb/sec
> of real throughput on a PCIe link theoretically capable of 16 Gb/sec
> seems pretty good to me.

For transfers with only 4 byte payloads, I get about 6.5 MB/sec over a PCIe
4x link.  For small transfers, the overhead is huge.
