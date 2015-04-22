From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3] Renesas Ethernet AVB driver
Date: Thu, 23 Apr 2015 01:50:40 +0300
Message-ID: <553825C0.2040600@cogentembedded.com>
References: <553814F0.40405@cogentembedded.com>	<20150422.181813.1931455043058560592.davem@davemloft.net>	<553821F8.8050300@cogentembedded.com> <20150422.184133.132510003688162502.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mitsuhiro.kimura.kc@renesas.com, f.fainelli@gmail.com,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	richardcochran@gmail.com, linux-sh@vger.kernel.org,
	masaru.nagai.vx@renesas.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20150422.184133.132510003688162502.davem@davemloft.net>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/23/2015 01:41 AM, David Miller wrote:


>>     Sigh... I'm seeing no way out of that then, only copying. :-(

> What exactly is the device's restriction?

    The frame data must be aligned on 32-bit boundary.

> Any reasonable modern chip allows one of two things.

> Either it allows arbitrary alignment of the start of the TX
> frame when DMA'ing.

> _or_

> It allows a variable number of pad bytes to be inserted by the
> driver before giving it to the card, which do not go onto the
> wire, in order to meet the device's DMA restrictions.

> For example, if the packet is only 2 byte aligned, you set the "ignore
> offset" to 2 and push two zero bytes in front of the ethernet frame
> before giving it to the card.

    I'm not seeing any padding logic on the TX path, only on the RX path (but 
it counts in 4-byte words, so seems quite useless).

> If a chip made in this day and era cannot do one of those two things,
> this is beyond disappointing and is a massive engineering failure.
> Whoever designed this chip made no investigation into how their
> hardware is going to be actually used.

    Too nad the Renesas SoC designers are not reading that. :-)

WBR, Sergei

