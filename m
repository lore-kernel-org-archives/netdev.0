From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC PATCH] 2.6.22.6 netfilter: sk_setup_caps in ip_make_route_harder
Date: Wed, 19 Sep 2007 17:17:17 +0200
Message-ID: <46F13D7D.6010603@trash.net>
References: <20070919093648.GA7491@router.lepton.home> <46F13999.30700@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: lepton <ytht.net@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33956 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753437AbXISPYT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 11:24:19 -0400
In-Reply-To: <46F13999.30700@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> lepton wrote:
> 
>>Hi,
>>  For local src packets, it is better to update sk_route_caps in
>>  ip_route_me_harder.
> 
> 
> 
> This seems like a good idea to me. But why only for local src
> (address) packets? This function can also be used for locally
> generated packet that have been (f.i.) NATed to a foreign
> address ...


Actually, I'm afraid it might break some setups. Rerouting is
done per packet, but if we cache the dst_entry for the socket,
all packets from that socket will be routed similar.

