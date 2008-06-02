From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/5] [VLAN]: Unclassified vlan packet
Date: Mon, 02 Jun 2008 14:48:15 +0200
Message-ID: <4843EC0F.8010300@trash.net>
References: <20080411135714.GA8137@tp64> <483B9EBE.5030703@trash.net>	 <b25c3fa70805262320h7edb4246wd017261fe7187b88@mail.gmail.com>	 <483BAA7F.6060408@trash.net> <b25c3fa70806011516q7ae6c913q9d6e431d664d176e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36539 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754248AbYFBMsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 08:48:20 -0400
In-Reply-To: <b25c3fa70806011516q7ae6c913q9d6e431d664d176e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joonwoo Park wrote:
> Patrick,
> Do you mind inserting a new flag to indicate vlan_tag is just for
> af_packet or not into sk_buff?
> I think if flag exists, we can pass vlan_tag to af_packet with just
> modifications of vlan_get_tag(), vlan_put_tag() and
> vlan_tag_present(),
> without patching for invalidation.

I've considered this, but that would mean that we report
the vlan tag for all devices layered on top, which seems
wrong.

For now I think I'm going to temporarily do something like
that so I can continue integrating the remaining patches
and fix it properly later.

