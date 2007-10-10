From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Evict tmp variable from the stack in ip6_evictor
Date: Wed, 10 Oct 2007 16:37:00 +0200
Message-ID: <470CE38C.2020607@trash.net>
References: <470CE1C8.9020000@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62945 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754221AbXJJOhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 10:37:04 -0400
In-Reply-To: <470CE1C8.9020000@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelyanov wrote:
> The list_head *tmp is used to help getting the first entry in
> the ip6_frag_lru_list list. There is a simpler way to do it


The exact same code exists in ip_fragment.c and nf_conntrack_reasm.c,
please also change it there.
