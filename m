From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 12/26] IPVS: Extend proto handler debug functions to handle
 IPv6.
Date: Wed, 11 Jun 2008 19:17:14 +0200
Message-ID: <4850089A.2090006@trash.net>
References: <1213204329-10973-1-git-send-email-juliusv@google.com> <1213204329-10973-13-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	horms@verge.net.au, davem@davemloft.net, vbusam@google.com
To: "Julius R. Volz" <juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46976 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762109AbYFKRWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 13:22:33 -0400
In-Reply-To: <1213204329-10973-13-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julius R. Volz wrote:
> Extend protocol handler packet debug functions for TCP, UDP, AH and ESP to
> handle IPv6. Make the main debug function call either a v4 or v6 version,
> depending on the packet protocol version.
>   

The only difference appears to be the address format and header
offset. You could save some duplication by using an af-independant
address debugging function and add a helper to get the proto offset.
Similar to how x_tables and nf_conntrack do it.

