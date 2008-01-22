From: Patrick McHardy <kaber@trash.net>
Subject: Re: [IPV4] ip_gre: should take care of CONFIG_IPV6_MODULE
Date: Tue, 22 Jan 2008 09:21:26 +0100
Message-ID: <4795A786.5080606@trash.net>
References: <4795A096.60904@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41527 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355AbYAVIVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 03:21:53 -0500
In-Reply-To: <4795A096.60904@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> If IPV6 is configured as a module, GRE code misses some IPV6 parts.


I believe this is intentional to avoid a runtime dependency on ipv6.
Fixing this without pulling in the ipv6 module would be preferrable.

