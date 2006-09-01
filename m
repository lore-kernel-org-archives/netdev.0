From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2.6.18] WE-21 support (core API)
Date: Fri, 01 Sep 2006 08:56:38 +0200
Message-ID: <1157093798.2878.30.camel@ux156>
References: <20060830005655.GA8405@bougret.hpl.hp.com>
	 <1157031138.16040.17.camel@ux156>
	 <20060831171258.GD11836@bougret.hpl.hp.com>
	 <200608311957.29206.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jt@hpl.hp.com, "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Javier Achirica <achirica@gmail.com>,
	Simon Kelley <simon@thekelleys.org.uk>,
	Jouni Malinen <jkmaline@cc.hut.fi>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Zhu Yi <yi.zhu@intel.com>, Pavel Roskin <proski@gnu.org>,
	"Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>,
	Jeroen Vreeken <pe1rxq@amsat.org>,
	Michael Wu <flamingice@sourmilk.net>,
	Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:25532 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751252AbWIAG4h
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 02:56:37 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200608311957.29206.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-08-31 at 19:57 +0200, Michael Buesch wrote:

> It is. Nobody says different. I think with "mainline" Johannes meant
> the wireless-dev tree. Merging nl80211 with softmac would indeed not
> make sense to me, too.

Actually, I do say different. I want softmac to be a consumer of nl80211
too, as well as all the fullmac drivers. I want to put all the ioctl
handling and all the mess with implicit semantics and special cases into
some common shim layer that simply calls the same methods you gave to
nl80211, so that drivers never ever need to bother with WE again.

johannes
