From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v5 1/2] Renesas Ethernet AVB driver proper
Date: Tue, 09 Jun 2015 01:41:12 +0300
Message-ID: <55761A08.1050503@cogentembedded.com>
References: <1752433.KgeJV8aUGv@wasted.cogentembedded.com>	<20150603.201204.761049104805679684.davem@davemloft.net>	<55760CB0.1020503@cogentembedded.com> <20150608.151954.191885697349673611.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	richardcochran@gmail.com, linux-sh@vger.kernel.org,
	mitsuhiro.kimura.kc@renesas.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20150608.151954.191885697349673611.davem@davemloft.net>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/09/2015 01:19 AM, David Miller wrote:

>>> Furthermore, you should pass the NAPI context into ravb_rx() and use

>>     I guess I should have one NAPI context per RX queue?

> Yes.

    Thanks, done.

>>> it so that you can invoke napi_gro_receive() on all of the packets and
>>> therefore support GRO.

>>     Hmm, I don't think I have a hardware support for generic RX offload...
>> I'm still unsure what it is anyway -- is it used for IP packet
>> defragmentation?

> It's completely implemented in software, you don't need to do anything
> other than properly invoke napi_gro_receive().

    Not even set NETIF_F_GRO?

WBR, Sergei

