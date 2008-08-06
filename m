From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: iproute2 proposal
Date: Wed, 6 Aug 2008 13:38:21 +0300
Message-ID: <200808061338.21537.denys@visp.net.lb>
References: <200808060125.38260.denys@visp.net.lb> <200808061322.54655.denys@visp.net.lb> <48997C2C.8050208@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:47735 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755052AbYHFKjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 06:39:10 -0400
In-Reply-To: <48997C2C.8050208@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wednesday 06 August 2008, Patrick McHardy wrote:
> It would be nicer to avoid the initialization in ll_init_map() as
> you did in your first patch and add an explicit ll_invalidate_map()
> and call it when necessary (ip link add/del/change(?), ip tunnel
> add/del/change(?)).

It is more than that. I must also invalidate in monitor mode, since this is 
very volatile variable. In monitor mode very possible that interfaces can be 
changed. Also i guess it is not required and better to invalidate 
in "printing" functions?

If it is ok, i will try to do patch in this way now.
