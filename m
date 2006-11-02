From: "Simon Barber" <simon@devicescape.com>
Subject: RE: [patch] d80211: use pfifo_qdisc_ops rather than d80211-specific qdisc
Date: Thu, 2 Nov 2006 13:27:59 -0800
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F018B5E78@dhost002-46.dex002.intermedia.net>
References: <20061102193839.4884ae56@logostar.upir.cz>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Christoph Hellwig" <hch@infradead.org>,
	"James Ketrenos" <jketreno@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Jeff Garzik" <jeff@garzik.org>,
	"Patrick McHardy" <kaber@trash.net>,
	"David Kimdon" <dwhedon@devicescape.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:23833 "EHLO
	dhost002-46.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1752640AbWKBV1y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 16:27:54 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20061102193839.4884ae56@logostar.upir.cz>
To: "Jiri Benc" <jbenc@suse.cz>, "Sven-Haegar Koch" <haegar@sdinet.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Perhaps the solution is to allow the prefix to be a kernel configuration
item?

Simon 

-----Original Message-----
From: Jiri Benc [mailto:jbenc@suse.cz] 
Sent: Thursday, November 02, 2006 10:39 AM
To: Sven-Haegar Koch
Cc: Christoph Hellwig; James Ketrenos; John W. Linville; Simon Barber;
Jeff Garzik; Patrick McHardy; David Kimdon; netdev@vger.kernel.org
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather than
d80211-specific qdisc

On Thu, 2 Nov 2006 17:09:24 +0100 (CET), Sven-Haegar Koch wrote:
> At least the ones used on my machines all do.
> (Debian Sarge, Etch and Unstable)
> The configfiles can be changed without problems to use any device 
> name, but needing to edit various files just for a kernel update would

> inhibt me from just trying a new version until I really know I would 
> not need to go back to the old version again.

Then your config scripts don't work with Prism and Zydas cards.
Something is broken with your setup.

> (Switching wireless from eth1 to eth2 after copying the harddisk 
> contents to a new laptop was work enough, but at least expected with a

> new machine and changed hardware)

Because nobody can guarantee you even the order of your Ethernet
interfaces with newer kernels (e.g. your eth0 Ethernet card may become
eth1 at any
time) and it will become even worse with the parallel device discovery,
your setup is going to explode anyway.

Sorry, I can't take this as an argument. Using your argumentation, we
must preserve wlan0 name because scripts of zd1201 users will break
otherwise.
Or - wait a moment - no no, we must preserve ath0 name because of
madwifi users - and oh, we must preserve eth1 (not ethX because the
scripts cannot deal with it) because of ipw users. And we must
definitely ensure that card numbers won't ever change. Even if you uplug
them and replug to another slots in a different order.

Sorry, that cannot work.

 Jiri

--
Jiri Benc
SUSE Labs
