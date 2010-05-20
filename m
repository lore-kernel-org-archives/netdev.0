From: Patrick McHardy <kaber@trash.net>
Subject: Re: RFC: netfilter: synproxy iptables target
Date: Thu, 20 May 2010 16:11:28 +0200
Message-ID: <4BF54310.6030004@trash.net>
References: <AANLkTimp6S7MpwDAT8l-M0ZWjs2HIcUEfL5f8j9-QDZh@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53403 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752571Ab0ETOL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 10:11:28 -0400
In-Reply-To: <AANLkTimp6S7MpwDAT8l-M0ZWjs2HIcUEfL5f8j9-QDZh@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao wrote:
> I have implemented a simple SYNPROXY iptables target. It is much like
> the SYNPROXY implementation in pf of OpenBSD, but won't have state
> until the first connection is established with the help of syncookies.
> The code is hosted at github:
> 
> http://github.com/xiaosuo/xiaosuo/tree/master/synproxy/
> 
> Currently, it can work with firewall and local socket.
> 
> It is in the very early stage, and ugly. And I will add --timeout
> parameter to this target as TCP_DFER_ACCEPT, so I can do NAT basing on
> the request data.
> 
> i.e.
> 
> iptables -t nat -A OUTPUT -p tcp -m synproxy --http-url "*.jpg" -j
> DNAT --to-destination $image_http_server:80
> 
> And is there any chance to merge it into mainline?

If you can state a good use case, sure. I don't know much about the
PF synproxy myself.
