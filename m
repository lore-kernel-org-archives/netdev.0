From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [RFC] Alternate WE-21 support (core API)
Date: Fri, 8 Sep 2006 09:13:45 -0700
Message-ID: <20060908161345.GA27036@bougret.hpl.hp.com>
References: <20060830005655.GA8405@bougret.hpl.hp.com> <1157031138.16040.17.camel@ux156> <20060831135112.GA6097@jm.kir.nu> <1157032805.16040.21.camel@ux156> <20060906205538.GA29767@tuxdriver.com> <20060906213053.GA21719@bougret.hpl.hp.com> <20060908142913.GD23852@tuxdriver.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Jouni Malinen <jkmaline@cc.hut.fi>, netdev@vger.kernel.org,
	Javier Achirica <achirica@gmail.com>,
	Simon Kelley <simon@thekelleys.org.uk>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Zhu Yi <yi.zhu@intel.com>, Pavel Roskin <proski@gnu.org>,
	"Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>,
	Jeroen Vreeken <pe1rxq@amsat.org>,
	Michael Wu <flamingice@sourmilk.net>,
	Denis Vlasenko <vda@ilport.com.ua>,
	Michael Buesch <mbuesch@freenet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from madara.hpl.hp.com ([192.6.19.124]:3307 "EHLO madara.hpl.hp.com")
	by vger.kernel.org with ESMTP id S1750900AbWIHQT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2006 12:19:57 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
In-Reply-To: <20060908142913.GD23852@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 08, 2006 at 10:29:23AM -0400, John W. Linville wrote:
> On Wed, Sep 06, 2006 at 02:30:53PM -0700, Jean Tourrilhes wrote:
> > On Wed, Sep 06, 2006 at 04:55:44PM -0400, John W. Linville wrote:
> 
> > > + * V20 to V21
> > > + * ----------
> > > + *	- Remove (struct net_device *)->get_wireless_stats()
> > > + *	- Change length in ESSID and NICK to strlen() instead of strlen()+1
> > > + *	- Add IW_RETRY_SHORT/IW_RETRY_LONG retry modifiers
> > > + *	- Add explicit flag to tell stats are in 802.11k RCPI : IW_QUAL_RCPI
> > 
> > 	Personally, I would also add this :
> > 
> > + *	- Power/Retry relative values no longer * 100000
> >
> > 	Three reason :
> > 		1) It's a cleanup and does not add any new feature
> > 		2) It does not change the rest of the patches
> > 		3) Userspace part has already gone in distro, not
> > including this bit would mean breaking userspace.
> 
> Is there any code that corresponds to that?  Or does the comment
> simply indicate policy?

	There is no code in the core of the WE, so it only indicates
policy. But, I believe policy change need to be documented.
	On the other hand you will find code in the tiacx patch.

> > 	The other bits can be included at a later time ;-)
> 
> Well, maybe.  But, I think we should now consider WE to be in
> maintenance mode.  I think nl80211 is the future, as long as Johannes
> delivers.

	We'll see. WE has been supposed to be replaced any time soon
for the last 3 years. And I don't believe nl80211 will address legacy
driver and non-802.11 hardware.

> Thanks,
> 
> John

	Thanks, and have fun...

	Jean
