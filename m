From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [PATCH 2.6.18] WE-21 support (core API)
Date: Thu, 31 Aug 2006 10:12:58 -0700
Message-ID: <20060831171258.GD11836@bougret.hpl.hp.com>
References: <20060830005655.GA8405@bougret.hpl.hp.com> <1157031138.16040.17.camel@ux156>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Javier Achirica <achirica@gmail.com>,
	Simon Kelley <simon@thekelleys.org.uk>,
	Jouni Malinen <jkmaline@cc.hut.fi>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Zhu Yi <yi.zhu@intel.com>, Pavel Roskin <proski@gnu.org>,
	"Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>,
	Jeroen Vreeken <pe1rxq@amsat.org>,
	Michael Wu <flamingice@sourmilk.net>,
	Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>,
	Michael Buesch <mbuesch@freenet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gundega.hpl.hp.com ([192.6.19.190]:58350 "EHLO
	gundega.hpl.hp.com") by vger.kernel.org with ESMTP id S1750715AbWHaRUJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 13:20:09 -0400
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
> 
> I strongly disagree to these.

	And I strongly disagree with your disagrement ;-)

> What's the point of adding more ioctls that we'll be implementing them
> as wrappers around nl80211? Right now, those new ioctls/options aren't
> implemented in *any* driver at all so they're completely useless, and
> just add more to the pile of historic baggage we end up carrying around.
> If we add these to mainline now, it's another thing we'll have to carry
> for a long time even though it currently has no users...

	I'm sorry to say it like this, but I hope my work will not be
impacted by vaporware. How many drivers are currently converted to
nl80211 ?
	I hope you realised that we are all trying to make 802.11
support progress, each through our own ways. And that all those
efforts are not conflicting with each other.
	The reason why those new features are good for you :
		o They give you a template on how you could implement
those features in nl80211, saving you design time.
		o The goal is to replace private ioctls (driver
specific) with standard ioctls. So, in other words, they actually
*reduce* the historic baggage and make it easier to wrap around those
functions if you want (I won't expect you to wrap around *every* WE).

	Personally, I still have not seen the point of nl80211, as the
full Wireless Extension is already available over NetLink (have you
tried it ?). But, I shut up my big mouth, and let you work freely on
it, as a mark of respect for your work and intentions, and also
because something good may come out of it.

> I'd much prefer merging nl80211 and putting any really *new* stuff into
> it directly. Of course this fragments the user space API for a while
> since you need to use two APIs then for the time being to configure all
> things, but we can move over all the rest of the configuration gradually
> and before we end up in mainline with the new API we can have that
> finished.

	Good luck with that plan, user-space is notorious to not like
entropy...
	Personally, I though that the plan that was more or less the
consensus that the "new API" would be targeted mostly at the
DeviceScape stack, as it seems difficult to offer the full feature set
of that stack through WE. So, I would have expected the development of
the "new API" to be somewhat in sync with the integration of the
DeviceScape stack.

> Or putting it the other way round, I'm ok with
>  * cleaning up the ssid mess
>  * adding RCPI (we'll probably be using it in nl80211 anyway, so it's
>    easier if we add it now and declare no support for other things)
>  * getting rid of get_wireless_stats (good one!)
>    [actually, I plan to get rid of wireless_handlers too]

	And if you look closely, you will realise the other features
are also good for you ;-)

> johannes

	Have fun...

	Jean
