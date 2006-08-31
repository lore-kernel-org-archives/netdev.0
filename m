From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2.6.18] WE-21 support (core API)
Date: Thu, 31 Aug 2006 16:00:05 +0200
Message-ID: <1157032805.16040.21.camel@ux156>
References: <20060830005655.GA8405@bougret.hpl.hp.com>
	 <1157031138.16040.17.camel@ux156>  <20060831135112.GA6097@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jt@hpl.hp.com, "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Javier Achirica <achirica@gmail.com>,
	Simon Kelley <simon@thekelleys.org.uk>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Zhu Yi <yi.zhu@intel.com>, Pavel Roskin <proski@gnu.org>,
	"Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>,
	Jeroen Vreeken <pe1rxq@amsat.org>,
	Michael Wu <flamingice@sourmilk.net>,
	Denis Vlasenko <vda@ilport.com.ua>,
	Michael Buesch <mbuesch@freenet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:19844 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750788AbWHaN7s
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 09:59:48 -0400
To: Jouni Malinen <jkmaline@cc.hut.fi>
In-Reply-To: <20060831135112.GA6097@jm.kir.nu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-08-31 at 06:51 -0700, Jouni Malinen wrote:

> I don't know about the others, but long/short retry limits have users
> (e.g., Host AP driver) and these drivers are currently forced to use a
> hack to do this without this cleanup. Furthermore, this part does not
> add a new ioctl.

It does, however, add new parameters and things that'd need to be
translated in the compat layer later. Hence, even there, I'd prefer to
add them directly into nl80211. However, the compat code for that
shouldn't be that bad, so I can see that as a softer target :) But I
don't want to see new ioctls for sure.

johannes
