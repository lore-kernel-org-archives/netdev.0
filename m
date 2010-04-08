From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] net/wireless/libertas: do not call wiphy_unregister()
	w/o wiphy_register()
Date: Thu, 8 Apr 2010 15:03:58 -0400
Message-ID: <20100408190358.GB2999@tuxdriver.com>
References: <1269875658-3324-1-git-send-email-daniel@caiaq.de> <201003301149.13462.hs4233@mail.mn-solutions.de> <20100330105029.GO30801@buzzloop.caiaq.de> <201003301259.23973.hs4233@mail.mn-solutions.de> <1269968673.3019.37.camel@localhost.localdomain> <20100330172008.GD13120@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Holger Schurig <hs4233@mail.mn-solutions.de>,
	Daniel Mack <daniel@caiaq.de>,
	libertas-dev@lists.infradead.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50798 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932983Ab0DHTPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 15:15:24 -0400
Content-Disposition: inline
In-Reply-To: <20100330172008.GD13120@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 30, 2010 at 01:20:08PM -0400, John W. Linville wrote:
> On Tue, Mar 30, 2010 at 10:04:33AM -0700, Dan Williams wrote:
> > On Tue, 2010-03-30 at 12:59 +0200, Holger Schurig wrote:
> > > > I don't get your point. The patch I submitted fixes an Ooops in the
> > > > driver, due to wrong handling of an API. What does that have to do with
> > > > principle discussions about the frameworks in use?
> > > 
> > > I asked if there is a better method, and you said that you would test a better 
> > > solution. That means that someone else should make a better solution.
> > > 
> > > I just pointed out that I won't be the one who creates the better solution, 
> > > because for fundamental reasons I don't see the libertas+cfg80211 approach 
> > > going forward. That issue has nothing to do with you or your patch, so please 
> > > don't feel offended or confused.
> > 
> > Fine; just rip out the mesh code and do the vanilla cfg80211 conversion
> > for infra & adhoc, and we'll add the mesh code back later.  I don't have
> > time to do the cfg80211 bits, neither do the OLPC guys (AFAIK), so lets
> > take advantage of your willingness to do this and just move the driver
> > forward.
> 
> Someone post a feature removal patch, please?

Ping?

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
