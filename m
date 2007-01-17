From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Wed, 17 Jan 2007 23:06:54 +0000
Message-ID: <20070117230654.GA9387@infradead.org>
References: <20070116185524.GA5681@dmt> <1169020333.9175.15.camel@johannes.berg> <20070117184204.GA3899@dmt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	Dan Williams <dcbw@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:33243 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917AbXAQXHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jan 2007 18:07:06 -0500
To: Marcelo Tosatti <marcelo@kvack.org>
Content-Disposition: inline
In-Reply-To: <20070117184204.GA3899@dmt>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 17, 2007 at 04:42:04PM -0200, Marcelo Tosatti wrote:
> And using the Marvell provided firmware is a requirement for OLPC
> machines, where the CPU will be shut down but the chip+firmware will
> continue to forward packets in the mesh network (there are extreme power
> saving constraints on these machines).

Well, than it probably doesn't go into mainline if you want to continue
doing this stupid layering violation.

