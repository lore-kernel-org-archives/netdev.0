From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 1/2] Renesas Ethernet AVB driver proper
Date: Mon, 08 Jun 2015 15:43:26 -0700 (PDT)
Message-ID: <20150608.154326.2037112726253299896.davem@davemloft.net>
References: <55760CB0.1020503@cogentembedded.com>
	<20150608.151954.191885697349673611.davem@davemloft.net>
	<55761A08.1050503@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	richardcochran@gmail.com, linux-sh@vger.kernel.org,
	mitsuhiro.kimura.kc@renesas.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <55761A08.1050503@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Tue, 09 Jun 2015 01:41:12 +0300

> On 06/09/2015 01:19 AM, David Miller wrote:
> 
>> It's completely implemented in software, you don't need to do anything
>> other than properly invoke napi_gro_receive().
> 
>    Not even set NETIF_F_GRO?

Yes, you have to set that by default for it to go.  Thankfully this is
also "in software" ;-)

