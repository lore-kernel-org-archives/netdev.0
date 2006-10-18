From: David Kimdon <david.kimdon@devicescape.com>
Subject: Re: [patch 3/3] d80211: silence sparse warning: bad constant expression
Date: Wed, 18 Oct 2006 08:12:27 -0700
Message-ID: <20061018151227.GA9777@devicescape.com>
References: <20061009201102.GA10661@devicescape.com> <20061018155607.2320a5fa@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:29831 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1161159AbWJRPMi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 11:12:38 -0400
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20061018155607.2320a5fa@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 18, 2006 at 03:56:07PM +0200, Jiri Benc wrote:
> On Mon, 9 Oct 2006 13:11:02 -0700, David Kimdon wrote:
> > --- wireless-dev.orig/net/d80211/ieee80211_sta.c
> > +++ wireless-dev/net/d80211/ieee80211_sta.c
> > @@ -930,8 +930,8 @@ static void ieee80211_rx_mgmt_auth(struc
> >  		printk(KERN_DEBUG "%s: AP denied authentication (auth_alg=%d "
> >  		       "code=%d)\n", dev->name, ifsta->auth_alg, status_code);
> >  		if (status_code == WLAN_STATUS_NOT_SUPPORTED_AUTH_ALG) {
> > -			const int num_algs = 3;
> > -			u8 algs[num_algs];
> > +			u8 algs[3];
> > +			const int num_algs = ARRAY_SIZE(algs);
> 
> Wouldn't it be better just to use ARRAY_SIZE(algs) and get rid of
> num_algs completely?

I actually think the code reads slightly cleaner using num_algs, but
don't have a strong preference.  I'd be happy to make the change if
removing num_algs is preferred.

-David
