From: "David S. Miller" <davem@davemloft.net>
Subject: Re: VJ Channel API - driver level (README)
Date: Tue, 02 May 2006 23:49:36 -0700 (PDT)
Message-ID: <20060502.234936.109637839.davem@davemloft.net>
References: <1145118379.2324.18.camel@localhost.localdomain>
	<4457CF53.7050000@stud.feec.vutbr.cz>
	<4457E2E1.3030809@neterion.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:43428
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965109AbWECGtk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 May 2006 02:49:40 -0400
To: alex@neterion.com
In-Reply-To: <4457E2E1.3030809@neterion.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


BTW another thing to keep in mind, besides the fact that we should be
designing driver APIs at this point at all, is that no implementation
should do MMIOs to the card to insert or delete netchannel lookup
entries.

Rather, it should be communicated to the card in a lazy fashion using
DMA.

Otherwise, net channels will have the same connection rate performance
problems that TOE has.
