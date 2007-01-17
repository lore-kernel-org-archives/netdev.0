From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Wed, 17 Jan 2007 23:09:46 +0000
Message-ID: <20070117230945.GB9387@infradead.org>
References: <20070116185524.GA5681@dmt> <20070117141103.0e468bf4@griffin.suse.cz> <1169046072.2750.10.camel@localhost.localdomain> <1169047134.9175.49.camel@johannes.berg> <1169055788.2550.44.camel@localhost.localdomain> <1169056847.2550.56.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Jiri Benc <jbenc@suse.cz>, Marcelo Tosatti <marcelo@kvack.org>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:33257 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751129AbXAQXKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jan 2007 18:10:02 -0500
To: Dan Williams <dcbw@redhat.com>
Content-Disposition: inline
In-Reply-To: <1169056847.2550.56.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 17, 2007 at 01:00:47PM -0500, Dan Williams wrote:
> Furthermore, I might add that the entire reason this part was chosen for
> OLPC was because it _is_ fullmac.
> 
> To drive down power consumption, the OLPC puts the host CPU to sleep but
> keeps the 8388 powered on.  That consumes around 400mW max.  But it
> allows the 8388 to continue routing other laptops' packets over the mesh
> *while the host CPU is asleep*.

We're not going to put a lot of junk into the kernel just because the OLPC
folks decide to do odd powermanagment schemes.

