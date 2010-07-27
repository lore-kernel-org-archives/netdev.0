From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 4/4] wireless: Convert wiphy_debug macro to
 function
Date: Tue, 27 Jul 2010 11:34:25 -0700
Message-ID: <1280255665.2082.119.camel@Joe-Laptop.home>
References: <cover.1280177971.git.joe@perches.com>
	 <8e7aa541ec8fb92e1166920a4eb704aa5f851b71.1280177971.git.joe@perches.com>
	 <20100727180556.GE31694@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100727180556.GE31694@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-07-27 at 14:05 -0400, John W. Linville wrote:
> > --- a/net/wireless/core.c
> > +++ b/net/wireless/core.c
> > @@ -907,3 +907,56 @@ static void __exit cfg80211_exit(void)
> >  	destroy_workqueue(cfg80211_wq);
> >  }
> >  module_exit(cfg80211_exit);
> > +
> > +#ifdef __KERNEL__
> 
> Do we need this part?

No, not really.

I'm not too sure about the need for the added
cfg80211.h #ifdef __KERNEL__ either.
