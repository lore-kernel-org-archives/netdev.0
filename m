From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 13/25] ipvs: remove check for IP_VS_CONN_F_SYNC from
 ip_vs_bind_dest
Date: Mon, 07 May 2012 22:17:42 -0400 (EDT)
Message-ID: <20120507.221742.778683822772023608.davem@davemloft.net>
References: <1336436539-5880-14-git-send-email-pablo@netfilter.org>
	<20120507.213607.2054696052002528963.davem@davemloft.net>
	<alpine.LNX.2.01.1205080414470.19642@frira.vanv.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: jengelh@inai.de
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1205080414470.19642@frira.vanv.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@inai.de>
Date: Tue, 8 May 2012 04:15:15 +0200 (CEST)

> On Tuesday 2012-05-08 03:36, David Miller wrote:
> 
>>From: pablo@netfilter.org
>>Date: Tue,  8 May 2012 02:22:07 +0200
>>
>>> +		/* It is a normal connection, so modify the counters
>>> +		 * according to the flags, later the protocol can
>>> +		 * update them on state change */
>>
>>Rather:
>>
>>		/* It is a normal connection, so modify the counters
>>		 * according to the flags, later the protocol can
>>		 * update them on state change
>>		 */
> 
> Well, CodingStyle even says

We've discussed this to death, subsystem maintainers can ask
for whatever they want and this is what I've asked for for years.
