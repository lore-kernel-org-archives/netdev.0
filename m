From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH net-next 4/4] wireless: Convert wiphy_debug macro to
 function
Date: Tue, 27 Jul 2010 14:57:28 -0400
Message-ID: <20100727185728.GF31694@tuxdriver.com>
References: <cover.1280177971.git.joe@perches.com>
 <8e7aa541ec8fb92e1166920a4eb704aa5f851b71.1280177971.git.joe@perches.com>
 <20100727180556.GE31694@tuxdriver.com>
 <1280255665.2082.119.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1280255665.2082.119.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 27, 2010 at 11:34:25AM -0700, Joe Perches wrote:
> On Tue, 2010-07-27 at 14:05 -0400, John W. Linville wrote:
> > > --- a/net/wireless/core.c
> > > +++ b/net/wireless/core.c
> > > @@ -907,3 +907,56 @@ static void __exit cfg80211_exit(void)
> > >  	destroy_workqueue(cfg80211_wq);
> > >  }
> > >  module_exit(cfg80211_exit);
> > > +
> > > +#ifdef __KERNEL__
> > 
> > Do we need this part?
> 
> No, not really.
> 
> I'm not too sure about the need for the added
> cfg80211.h #ifdef __KERNEL__ either.

Good point -- I'll remove both of them.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
