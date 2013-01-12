From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: Re: [RFC PATCH 5/6] firewire net: IPv6 support (RFC3146).
Date: Sat, 12 Jan 2013 18:15:07 +0100
Message-ID: <50F19A1B.7050200@gmail.com>
References: <50F17171.3050105@linux-ipv6.org> <20130112162224.10e2aa44@stein> <20130112180058.0289baba@stein>
Reply-To: stephan.gatzka@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:48243 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753913Ab3ALRPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 12:15:11 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so1105860eaa.19
        for <netdev@vger.kernel.org>; Sat, 12 Jan 2013 09:15:09 -0800 (PST)
In-Reply-To: <20130112180058.0289baba@stein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Another thing:  As far as I understand, the current code assumes that
> peers will use the same unicast_FIFO for IPv4 unicast as for IPv6
> unicast.  This is not necessarily true.  Either firewire-net needs to
> maintain two lists of peers (one for IPv4, another for IPv6), or it needs
> to maintain two unicast_FIFOs per peer.
>

Thanks for pointing that out. I would go for two unicast_Fifos per peer.
