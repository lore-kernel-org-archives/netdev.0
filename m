From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Thu, 18 Jan 2007 10:41:45 -0500
Message-ID: <1169134905.2788.16.camel@localhost.localdomain>
References: <20070116185524.GA5681@dmt>
	 <1169020333.9175.15.camel@johannes.berg> <20070117184204.GA3899@dmt>
	 <20070117230654.GA9387@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Marcelo Tosatti <marcelo@kvack.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:38330 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752040AbXARPlR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jan 2007 10:41:17 -0500
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20070117230654.GA9387@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-01-17 at 23:06 +0000, Christoph Hellwig wrote:
> On Wed, Jan 17, 2007 at 04:42:04PM -0200, Marcelo Tosatti wrote:
> > And using the Marvell provided firmware is a requirement for OLPC
> > machines, where the CPU will be shut down but the chip+firmware will
> > continue to forward packets in the mesh network (there are extreme power
> > saving constraints on these machines).
> 
> Well, than it probably doesn't go into mainline if you want to continue
> doing this stupid layering violation.

In the future we'll likely need some layering to support the 8385
SDIO/CF variant, but most likely not in way the USB support is currently
excessively layered and abstracted.

Dan


