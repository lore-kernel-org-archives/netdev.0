From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3] Renesas Ethernet AVB driver
Date: Thu, 23 Apr 2015 01:34:32 +0300
Message-ID: <553821F8.8050300@cogentembedded.com>
References: <553804CA.1030605@cogentembedded.com>	<20150422.164242.2185477513394713122.davem@davemloft.net>	<553814F0.40405@cogentembedded.com> <20150422.181813.1931455043058560592.davem@davemloft.net>
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
Received: from mail-la0-f44.google.com ([209.85.215.44]:35121 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934518AbbDVWeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 18:34:37 -0400
Received: by labbd9 with SMTP id bd9so411675lab.2
        for <netdev@vger.kernel.org>; Wed, 22 Apr 2015 15:34:35 -0700 (PDT)
In-Reply-To: <20150422.181813.1931455043058560592.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/23/2015 01:18 AM, David Miller wrote:

>>>>      Hmm, I've been digging in the net core, and was unable to see where TX
>>>>      skb's get their NET_IP_ALIGN bytes reserved. Have I missed something?
>>>>      Probably need to print out skb's fields...

>>> NET_IP_ALIGN is for receive, not transmit.

>>     But when I print 'skb->data' from the ndo_start_xmit() method (in the
>>     'sh_eth' driver), all addresses end with 2, so it looks like
>>     NET_IP_ALIGN gets added somewhere...

> It's the IPV4 header which is 4 byte aligned, then the ethernet header
> is pushed which is 14 bytes.

    Sigh... I'm seeing no way out of that then, only copying. :-(

WBR, Sergei
