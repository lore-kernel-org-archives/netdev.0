From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH] Bluetooth: Fix BT_L2CAP and BT_SCO in Kconfig
Date: Thu, 3 Mar 2011 09:05:12 -0500
Message-ID: <20110303140512.GB8969@tuxdriver.com>
References: <20110226013639.GA2166@joana>
 <1298684485-3081-1-git-send-email-padovan@profusion.mobi>
 <20110302.215433.39198854.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110302.215433.39198854.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 02, 2011 at 09:54:33PM -0800, David Miller wrote:
> From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
> Date: Fri, 25 Feb 2011 22:41:25 -0300
> 
> > If we want something "bool" built-in in something "tristate" it can't
> > "depend on" the tristate config option.
> > 
> > Report by DaveM:
> > 
> >    I give it 'y' just to make it happen, for both, and afterways no
> >    matter how many times I rerun "make oldconfig" I keep seeing things
> >    like this in my build:
> > 
> > scripts/kconfig/conf --silentoldconfig Kconfig
> > include/config/auto.conf:986:warning: symbol value 'm' invalid for BT_SCO
> > include/config/auto.conf:3156:warning: symbol value 'm' invalid for BT_L2CAP
> > 
> > Reported-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> > Signed-off-by: Gustavo F. Padovan <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
> 
> I think this approach is fine since it mirrors what we use in other similar
> situations.
> 
> I am assuming this patch will propagate via bluetooth --> wireless --> me.

Yes, I have it queued.

-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
