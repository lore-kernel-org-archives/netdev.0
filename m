From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] Renesas Ethernet AVB driver
Date: Wed, 22 Apr 2015 16:42:42 -0400 (EDT)
Message-ID: <20150422.164242.2185477513394713122.davem@davemloft.net>
References: <SIXPR06MB03142A49C392C39922DC2BDA3EE0@SIXPR06MB031.apcprd06.prod.outlook.com>
	<20150422.113654.1169277303695917496.davem@davemloft.net>
	<553804CA.1030605@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mitsuhiro.kimura.kc@renesas.com, f.fainelli@gmail.com,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	richardcochran@gmail.com, linux-sh@vger.kernel.org,
	masaru.nagai.vx@renesas.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35607 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755531AbbDVUmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 16:42:46 -0400
In-Reply-To: <553804CA.1030605@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Wed, 22 Apr 2015 23:30:02 +0300

>    Hmm, I've been digging in the net core, and was unable to see where TX
>    skb's get their NET_IP_ALIGN bytes reserved. Have I missed something?
>    Probably need to print out skb's fields...

NET_IP_ALIGN is for receive, not transmit.
