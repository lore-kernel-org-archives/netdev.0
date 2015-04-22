From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3] Renesas Ethernet AVB driver
Date: Thu, 23 Apr 2015 00:38:56 +0300
Message-ID: <553814F0.40405@cogentembedded.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:35958 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751957AbbDVVjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 17:39:01 -0400
Received: by lbbqq2 with SMTP id qq2so190467774lbb.3
        for <netdev@vger.kernel.org>; Wed, 22 Apr 2015 14:38:59 -0700 (PDT)
In-Reply-To: <20150422.164242.2185477513394713122.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/22/2015 11:42 PM, David Miller wrote:

>>     Hmm, I've been digging in the net core, and was unable to see where TX
>>     skb's get their NET_IP_ALIGN bytes reserved. Have I missed something?
>>     Probably need to print out skb's fields...

> NET_IP_ALIGN is for receive, not transmit.

    But when I print 'skb->data' from the ndo_start_xmit() method (in the 
'sh_eth' driver), all addresses end with 2, so it looks like NET_IP_ALIGN gets 
added somewhere...

WBR, Sergei
