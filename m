From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Thu, 18 Jan 2007 03:22:50 -0500
Message-ID: <20070118082250.GE11056@tuxdriver.com>
References: <20070116185524.GA5681@dmt> <20070117141103.0e468bf4@griffin.suse.cz> <1169046072.2750.10.camel@localhost.localdomain> <1169047134.9175.49.camel@johannes.berg> <1169055788.2550.44.camel@localhost.localdomain> <1169056847.2550.56.camel@localhost.localdomain> <20070117230945.GB9387@infradead.org> <45AEAEEB.6050603@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dcbw@redhat.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Jiri Benc <jbenc@suse.cz>, Marcelo Tosatti <marcelo@kvack.org>,
	netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2147 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752026AbXARJEs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jan 2007 04:04:48 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <45AEAEEB.6050603@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 17, 2007 at 06:19:07PM -0500, Jeff Garzik wrote:
> Christoph Hellwig wrote:
> >On Wed, Jan 17, 2007 at 01:00:47PM -0500, Dan Williams wrote:

> >>allows the 8388 to continue routing other laptops' packets over the mesh
> >>*while the host CPU is asleep*.
> >
> >We're not going to put a lot of junk into the kernel just because the OLPC
> >folks decide to do odd powermanagment schemes.
> 
> We're not going to ignore useful power management schemes just because 
> they don't fit neatly into a pre-existing category.
> 
> I think the request to determine how all this maps into MLME is fair, 
> though.

Definitely.  Also, I wonder if there was any attempt to evaluate how
the ieee80211 (or d80211) code might be extended in order to elimnate
the need for some of the libertas wlan_* files?

John
-- 
John W. Linville
linville@tuxdriver.com
