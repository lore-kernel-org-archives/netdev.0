From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/2] usbnet: Style cleanups
Date: Tue, 03 May 2011 12:05:59 -0700
Message-ID: <1304449559.1788.33.camel@Joe-Laptop>
References: <cover.1304445019.git.joe@perches.com>
	 <3592918df9ee156047042aae16531e96db0b7144.1304445019.git.joe@perches.com>
	 <201105032049.41433.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Oliver Neukum <oneukum@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201105032049.41433.oneukum@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-05-03 at 20:49 +0200, Oliver Neukum wrote:
> Am Dienstag, 3. Mai 2011, 20:17:57 schrieb Joe Perches:
> >  drivers/net/usb/usbnet.c |  625 +++++++++++++++++++++++----------------------
> >  1 files changed, 319 insertions(+), 306 deletions(-)
> > 
> > diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> > index 7bc9852..28aecbb 100644
> > --- a/drivers/net/usb/usbnet.c
> > +++ b/drivers/net/usb/usbnet.c
> > @@ -30,8 +30,8 @@
> >   * issues can usefully be addressed by this framework.
> >   */
> >  
> > -// #define     DEBUG                   // error path messages, extra info
> > -// #define     VERBOSE                 // more; success messages
> > +/* #define     DEBUG                   // error path messages, extra info */
> > +/* #define     VERBOSE                 // more; success messages */
> 
> Hi,

Hi Oliver.

> 1. please don't touch things like that. They are not comments in a semantic sense

We disagree.  Look for other uses of commented out DEBUG.

For instance, in drivers it's:
$ grep -rP --include=*.[ch] --exclude=drivers/staging "/\*\s*\#\s*define\s+DEBUG\b" drivers | wc -l
32

$ grep -rP --include=*.[ch] --exclude=drivers/staging "//\s*\#\s*define\s+DEBUG\b" drivers | wc -l
17

Treewide, there are 20 uses of //#define DEBUG

> if you are touching comments, please redo the multiline comments according to
> the coding style.

Read the patches, they are converted to appropriate form.

> 3. please delay these modifications until the patches against the oom problem have
> been applied

I think they're correct and don't feel a need to regenerate them
nor do I think micropatches for trivial stuff like this is necessary.

You want to be the maintainer for this stuff, it's your choice to
apply them, modify them to suit your taste or ignore them.

cheers, Joe
