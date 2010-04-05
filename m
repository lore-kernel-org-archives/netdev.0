From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 1/3] IPv6: Generic TTL Security Mechanism (original version)
Date: Mon, 05 Apr 2010 13:48:26 +0900
Message-ID: <4BB96B9A.3000203@linux-ipv6.org>
References: <20100403232103.923025940@vyatta.com> <20100403232922.489187907@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Pekka Savola <pekkas@netcore.fi>,
	Nick Hilliard <nick@inex.ie>, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:32879 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750732Ab0DEEsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 00:48:51 -0400
In-Reply-To: <20100403232922.489187907@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

(2010/04/04 8:21), Stephen Hemminger wrote:
> The original proposed code; the IPV6 and IPV4 socket options are seperate.
> With this method, the server does have to deal with both IPv4 and IPv6
> socket options and the client has to handle the different for each
> family.

I am for 1/3 (original), not for 2/3, 3/3.

Because we should allow users to set respective value
for IPv4 and IPv6, as we allow users to do so for TTL
and hoplimit itself.

--yoshfuji

