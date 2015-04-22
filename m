From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3] Renesas Ethernet AVB driver
Date: Wed, 22 Apr 2015 23:46:52 +0300
Message-ID: <553808BC.5020600@cogentembedded.com>
References: <SIXPR06MB03142A49C392C39922DC2BDA3EE0@SIXPR06MB031.apcprd06.prod.outlook.com>	<20150422.113654.1169277303695917496.davem@davemloft.net>	<553804CA.1030605@cogentembedded.com> <20150422.164242.2185477513394713122.davem@davemloft.net>
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
In-Reply-To: <20150422.164242.2185477513394713122.davem@davemloft.net>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 04/22/2015 11:42 PM, David Miller wrote:

>>     Hmm, I've been digging in the net core, and was unable to see where TX
>>     skb's get their NET_IP_ALIGN bytes reserved. Have I missed something?
>>     Probably need to print out skb's fields...

> NET_IP_ALIGN is for receive, not transmit.

    Hm, then 'skb->data' should be aligned to 4 byte boundary on TX, right?
If so, there should be no problem with removing the copy.

WBR, Segei

