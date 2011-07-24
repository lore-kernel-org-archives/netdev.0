From: "Guy, Wey-Yi" <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] iwlagn: wrap suspend/resume definitions in CONFIG_PM
 block
Date: Sun, 24 Jul 2011 16:01:07 -0700
Message-ID: <1311548467.5579.119.camel@wwguy-huron>
References: <20110724.030949.1727841105144911931.davem@davemloft.net>
	 <1311535150-28686-1-git-send-email-linville@tuxdriver.com>
	 <20110724.130840.1093555047179460794.davem@davemloft.net>
	 <20110724203956.GA29630@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Berg, Johannes" <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110724203956.GA29630-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 2011-07-24 at 13:39 -0700, John W. Linville wrote:
> On Sun, Jul 24, 2011 at 01:08:40PM -0700, David Miller wrote:
> > From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> > Date: Sun, 24 Jul 2011 15:19:10 -0400
> > 
> > > drivers/net/wireless/iwlwifi/iwl-agn.c:3464: error: unknown field 'suspend' specified in initializer
> > > drivers/net/wireless/iwlwifi/iwl-agn.c:3464: warning: initialization from incompatible pointer type
> > > drivers/net/wireless/iwlwifi/iwl-agn.c:3465: error: unknown field 'resume' specified in initializer
> > > drivers/net/wireless/iwlwifi/iwl-agn.c:3465: warning: initialization from incompatible pointer type
> > > 
> > > This was caused by commit c8ac61cf ("iwlagn: implement WoWLAN").
> > > 
> > > Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> > 
> > Since I already minimally fixed up my build locally last night I know
> > that your patch leads to a set of warnings because the methods whose
> > hookup are now commented out become completely unused and they are all
> > marked "static".  And recursively functions that those methods use
> > become unused too.
> > 
> > Did you turn off CONFIG_PM and test the build of this file to see
> > what the compiler actually does with it?
> > 
> > I'm checking in the following, but I expect much better from you John.
> 
> Sorry, Dave.  I confess that I was hoping for a quick fix on a Sunday afternoon. :-)
> 
> Thanks for making it better!
> 
> John
My mistake to not catch this to begin with, sorry for cause all the
trouble.

Wey

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
