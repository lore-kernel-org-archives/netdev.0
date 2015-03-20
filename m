From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next RFC v2] switchdev: bridge: drop hardware forwarded
 packets
Date: Fri, 20 Mar 2015 16:43:21 -0700
Message-ID: <550CB099.1030000@gmail.com>
References: <1426870714-3225-1-git-send-email-roopa@cumulusnetworks.com> <20150320.163655.474336751434677390.davem@davemloft.net> <550C92F3.50302@cumulusnetworks.com> <20150320220946.GB31769@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, sfeldma@gmail.com,
	jiri@resnulli.us, ronen.arad@intel.com, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>, roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:33209 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305AbbCTXoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 19:44:03 -0400
Received: by pdnc3 with SMTP id c3so122446240pdn.0
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 16:44:02 -0700 (PDT)
In-Reply-To: <20150320220946.GB31769@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/03/15 15:09, Andrew Lunn wrote:
>> since we have discussed this problem multiple times in switchdev meetings,
>> the intent of this RFC is to see get the code out and also see if
>> rocker or any other in-kernel
>> driver can use it.
> 
> The Marvell switches in DSA don't have any way to mark packets why
> they where forwarded towards the host. So i don't see how we could use
> this feature with these chips.

FWIW, the Broadcom tag format has a reason code which tells you why the
packet was forwarded, which you will typically enable plus the
corresponding protocol snooping (IGMP, MLD, ARP, DHCP etc...) to know
what to do. For these kinds of switches it would not be too hard to
discard such packets because you know why you got them in the first place.

Is it true just for the "old" DSA format and not for e.g: EDSA?
-- 
Florian
