From: Raz <raziebe@gmail.com>
Subject: Re: what is the expeted performance from a dual port 10G card ?
Date: Sun, 30 Nov 2008 09:25:55 +0200
Message-ID: <5d96567b0811292325j39f39a9ew343b430de72453d4@mail.gmail.com>
References: <5d96567b0811280511q1e3f7774j7eabce4810dae91a@mail.gmail.com>
	 <20081128135419.GH32518@solarflare.com>
	 <5d96567b0811290010r641388b7w179bc4af26bbf103@mail.gmail.com>
	 <20081129173442.GI32518@solarflare.com> <adamyfib173.fsf@cisco.com>
	 <Pine.LNX.4.64.0811291853010.12483@t2.domain.actdsltmp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Roland Dreier" <rdreier@cisco.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: "Trent Piepho" <tpiepho@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.247]:52211 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808AbYK3HZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2008 02:25:56 -0500
Received: by an-out-0708.google.com with SMTP id d40so716639and.1
        for <netdev@vger.kernel.org>; Sat, 29 Nov 2008 23:25:55 -0800 (PST)
In-Reply-To: <Pine.LNX.4.64.0811291853010.12483@t2.domain.actdsltmp>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 30, 2008 at 4:55 AM, Trent Piepho <tpiepho@freescale.com> wrote:
> On Sat, 29 Nov 2008, Roland Dreier wrote:
>> > The 8b10 encoding is already accounted for in the 2.5 Gbps figure;
>> > the raw bit rate is 3.125 Gbps.
>>
>> In addition, PCI Express transfers are broken up into packets, usually
>> with very small payloads (128 or 256 bytes are common).  So the packet
>> header overhead reduces throughput further, and then the transaction
>> layer adds further overhead.  Then transferring NIC control structures
>> over the link adds even more overhead.  So achieving 13.something Gb/sec
>> of real throughput on a PCIe link theoretically capable of 16 Gb/sec
>> seems pretty good to me.
I tested it both on PCIE2 and PCIE1 . same results.

> For transfers with only 4 byte payloads, I get about 6.5 MB/sec over a PCIe
> 4x link.  For small transfers, the overhead is huge.
>
Well, you are correct. I used packet size of 1.3k. when I increased to
9K a packet each port
reached ~7Gbps ( I am using pktgen). I used two cards, so I reached
28Gbps. BIOS settings for pci payload were AUTO,so i set it to 256
bytes but it made no difference, still 28Gbps. well, at least I know
what the problem is.
guys, I truly thank you all.
