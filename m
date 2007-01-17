From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Wed, 17 Jan 2007 10:01:12 -0500
Message-ID: <1169046072.2750.10.camel@localhost.localdomain>
References: <20070116185524.GA5681@dmt>
	 <20070117141103.0e468bf4@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Marcelo Tosatti <marcelo@kvack.org>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37534 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751410AbXAQPAz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jan 2007 10:00:55 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20070117141103.0e468bf4@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-01-17 at 14:11 +0100, Jiri Benc wrote:
> On Tue, 16 Jan 2007 16:55:24 -0200, Marcelo Tosatti wrote:
> > Diff can be found at 
> > http://dev.laptop.org/~marcelo/libertas-8388-16012007.patch
> > 
> > _Please_ review, this driver is targeted for mainline inclusion.
> 
> As long as there is yet another 802.11 stack inside, your chances to
> get this included are small.

There certainly isn't; with all the whining I've been doing over the
past two years about unified interfaces, we're not going to let a driver
through with Yet Another 802.11 Stack.  Sheesh, at least look at the
thing first.

The part is a mostly fullmac part that until now has been targetted at
the embedded market (PSP, N80 phone, etc).  That means that the driver
shouldn't be too large (airo is about 8000 kLOC without airo_cs) but for
some reason it still is; we're working on that.

But could we please be constructive here, and actually take a look at
the driver and point out problems?

Cheers,
Dan

[1] I've done a fair amount of work on this driver along with Marcelo


