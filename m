From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: under-performing bonded interfaces
Date: Wed, 21 Dec 2011 17:36:08 -0800
Message-ID: <20111221173608.0f04bc8b@nehalam.linuxnetplumber.net>
References: <CANj2EbeMRzicixHwrKpCQ3mMqQ1qbyjbRCxpW+CmVRREAhyeRQ@mail.gmail.com>
	<4EC44ECB.4050201@candelatech.com>
	<CANj2EbfrtbysEbj+gMa+fOhWo0EWjBXVyGkw8WyiPAV9nPduuQ@mail.gmail.com>
	<1321491449.2709.90.camel@bwh-desktop>
	<CANj2Ebdd89=Fk6i4e4Txsb3ANuzz-x4t+tT6CAnWDNZe0zvx9g@mail.gmail.com>
	<1321498314.2885.78.camel@deadeye>
	<CANj2Eben0hrP6KwxyA1WPqiqzm84w=J2_sdtrKtGvxdftuksqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org
To: Simon Chen <simonchennj@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36058 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752016Ab1LVBgL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Dec 2011 20:36:11 -0500
In-Reply-To: <CANj2Eben0hrP6KwxyA1WPqiqzm84w=J2_sdtrKtGvxdftuksqg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 Dec 2011 20:26:04 -0500
Simon Chen <simonchennj@gmail.com> wrote:

> Hi folks,
> 
> I added an Intel X520 card to both the sender and receiver... Now I
> have two 10G ports on a PCIe 2.0 x8 slot (5Gx8), so the bandwidth of
> the PCI bus shouldn't be the bottleneck.
> 
> Now the throughput test gives me around 16Gbps in aggregate. Any ideas
> how I can push closer to 20G? I don't quite understand where the
> bottleneck is now.

In my experience, Intel dual port cards can not run at full speed
when both ports are in use. You need separate slots to hit full
line rate.
