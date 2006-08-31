From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: [PATCH 2.6.18] WE-21 support (core API)
Date: Thu, 31 Aug 2006 06:51:13 -0700
Message-ID: <20060831135112.GA6097@jm.kir.nu>
References: <20060830005655.GA8405@bougret.hpl.hp.com> <1157031138.16040.17.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jt@hpl.hp.com, "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Javier Achirica <achirica@gmail.com>,
	Simon Kelley <simon@thekelleys.org.uk>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Zhu Yi <yi.zhu@intel.com>, Pavel Roskin <proski@gnu.org>,
	"Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>,
	Jeroen Vreeken <pe1rxq@amsat.org>,
	Michael Wu <flamingice@sourmilk.net>,
	Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>,
	Michael Buesch <mbuesch@freenet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.genealogia.fi ([194.100.116.229]:41873 "EHLO
	mail2.genealogia.fi") by vger.kernel.org with ESMTP id S932321AbWHaNxD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 09:53:03 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1157031138.16040.17.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 31, 2006 at 03:32:18PM +0200, Johannes Berg wrote:
> On Tue, 2006-08-29 at 17:56 -0700, Jean Tourrilhes wrote:
> > 		o modulation
> > 		o long/short retry
> > 		o relative power saving.

> What's the point of adding more ioctls that we'll be implementing them
> as wrappers around nl80211? Right now, those new ioctls/options aren't
> implemented in *any* driver at all so they're completely useless, and
> just add more to the pile of historic baggage we end up carrying around.
> If we add these to mainline now, it's another thing we'll have to carry
> for a long time even though it currently has no users...

I don't know about the others, but long/short retry limits have users
(e.g., Host AP driver) and these drivers are currently forced to use a
hack to do this without this cleanup. Furthermore, this part does not
add a new ioctl.

-- 
Jouni Malinen                                            PGP id EFC895FA
