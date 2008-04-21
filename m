From: Dan Williams <dcbw@redhat.com>
Subject: Re: [RFC: 2.6 patch] remove ieee80211_wx_{get,set}_auth()
Date: Mon, 21 Apr 2008 12:53:12 -0400
Message-ID: <1208796792.30994.16.camel@localhost.localdomain>
References: <20080421084834.GP26897@cs181133002.pp.htv.fi>
	 (sfid-20080421_094928_883145_7CB9F947)  <1208769074.26186.53.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54867 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754233AbYDUQ5T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 12:57:19 -0400
In-Reply-To: <1208769074.26186.53.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-04-21 at 11:11 +0200, Johannes Berg wrote:
> On Mon, 2008-04-21 at 11:48 +0300, Adrian Bunk wrote:
> > After the bcm43xx removal ieee80211_wx_{get,set}_auth() were no longer 
> > used.
> > 
> > Signed-off-by: Adrian Bunk <bunk@kernel.org>
> > 
> > ---
> > 
> >  include/net/ieee80211.h      |    8 ---
> >  net/ieee80211/ieee80211_wx.c |   89 -----------------------------------
> >  2 files changed, 97 deletions(-)
> 
> Interesting. I thought those would have been in softmac, removal sounds
> fine to me but I don't use the ieee80211 stack.

The only other two users of ieee80211 are ipw2100 and ipw2200, and they
both appear to implement the SIOCxIWAUTH calls privately.  So I think
these can go to the function slaughterhouse.  If somebody wants to unify
them later it would be better to start fresh anyway.

Dan


