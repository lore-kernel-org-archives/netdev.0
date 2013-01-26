From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH 15/19] sunrpc: don't warn for unused variable 'buf'
Date: Sat, 26 Jan 2013 13:34:56 +0000
Message-ID: <201301261334.56398.arnd@arndb.de>
References: <1359123276-15833-1-git-send-email-arnd@arndb.de> <201301252345.25829.arnd@arndb.de> <20130126110321.GE23505@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Myklebust, Trond" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"J. Bruce Fields" <bfields-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: "Russell King - ARM Linux" <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130126110321.GE23505-l+eeeJia6m9vn6HldHNs0ANdhmdF6hFW@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Saturday 26 January 2013, Russell King - ARM Linux wrote:
> On Fri, Jan 25, 2013 at 11:45:25PM +0000, Arnd Bergmann wrote:
> > On Friday 25 January 2013, Myklebust, Trond wrote:
> > > > -----Original Message-----
> > > > From: Arnd Bergmann [mailto:arnd-r2nGTMty4D4@public.gmane.org]
> > > > Marking it as __maybe_unused avoids a harmless gcc warning.
> > > 
> > > Alternatively, just declare it using the RPC_IFDEBUG() macro.
> > 
> > Right, makes sense: that's more consistent with other functions
> > doing the same thing. Thanks for taking a look.
> 
> NAK.
> 
> There is already a fix queued up as a result of a previous report I
> sent, but for some reason (which I didn't question) it was decided
> not to queue it for -rc.
> 
> See Bruce's reply on lkml: 20130108212816.GA24572-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org

Ok, makes sense. Then again, if that fix is queued for 3.9, maybe
it still makes sense to take the simpler fix into 3.8, and remove
it in 3.9 along with the other instances of RPC_IFDEBUG.

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
