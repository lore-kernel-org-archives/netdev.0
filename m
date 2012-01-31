From: Andrew Beverley <andy@andybev.com>
Subject: Re: IP forwarding on a linux IPSec gateway
Date: Tue, 31 Jan 2012 17:47:31 +0000
Message-ID: <1328032051.2018.15.camel@andy-laptop>
References: <B97B134FACB2024DB45F524AB0A7B7F2059F2B32@XMB-BGL-419.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Prashant Batra (prbatra)" <prbatra@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earth.simplelists.com ([89.16.184.171]:46549 "EHLO
	earth.simplelists.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753996Ab2AaR65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 12:58:57 -0500
In-Reply-To: <B97B134FACB2024DB45F524AB0A7B7F2059F2B32@XMB-BGL-419.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-01-27 at 15:31 +0530, Prashant Batra (prbatra) wrote:
> So, it's clear that linux gateway is able to protect the data and send
> to the connected gateway (ESP packets to outer IPs). And the second
> gateway is responding with ESP packet which is decoded on linux gateway
> and sent to the ip stack again by linux kernel (ICMP reply). But the
> reply doesn't reach the host on left subnet.

Didn't somebody else have a similar problem recently? He found that it
worked using one internet provider but not another. If you're not seeing
anything received in tcpdump in the left subnet, then I would suspect
that the packet is getting lost in the WAN somewhere. What happens when
you ping in the other direction?

Andy
