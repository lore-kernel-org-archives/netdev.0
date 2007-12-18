From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] MAINTAINERS: remove Adam Fritzler, update his email
 address in other sources
Date: Mon, 17 Dec 2007 20:28:00 -0800
Message-ID: <20071217202800.1c898441.akpm@linux-foundation.org>
References: <1197951126.4891.13.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Adam Fritzler <mid@zigamorph.net>,
	"James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	Mike Phillips <mikep@linuxtr.net>,
	Philip Blundell <philb@gnu.org>, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org, Adrian Bunk <bunk@stusta.de>
To: Joe Perches <joe@perches.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1197951126.4891.13.camel@localhost>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 17 Dec 2007 20:12:06 -0800 Joe Perches <joe@perches.com> wrote:

> Adam isn't a maintainer anymore.
> His old email address bounces.
> Update to new email address.
> 
> On Mon, Dec 17, 2007 at 01:03:48PM -0800, Joe Perches wrote:
> > > You seem to have an old email address in the
> > > linux-kernel MAINTAINERS file.
> > > Should it be deleted or changed?
> On Mon, 2007-12-17 at 19:27 -0800, Adam Fritzler wrote:
> > I am no longer actively involved. If you can mark me as a former point
> > of contact, that's fine, or you can just delete the entry. My name is
> > still in the source, but with the old address. It'd great if the
> > address in source was updated.
> 
> ...
>  
> -TMS380 TOKEN-RING NETWORK DRIVER
> -P:	Adam Fritzler
> -M:	mid@auk.cx
> -L:	linux-tr@linuxtr.net
> -W:	http://www.auk.cx/tms380tr/
> -S:	Maintained
>
> ...
>
> - * Added MCA support Adam Fritzler <mid@auk.cx>
> + * Added MCA support Adam Fritzler <mid@zigamorph.net>

This is fairly pointless - it'll just break again when Adam moves again.

Every problem can be solved with another layer of...

Please: just replace all instances with plain old "Adam Fritzler" and then
ensure that the lookup key "Adam Fritzler" has an accurate (and
non-duplicated anywhere else!) entry in MAINTAINERS or CREDITS or whatever.



btw, I cheerfully skipped all your spelling-fixes patches.  Some will have
stuck via subsystem maintainers but I have a secret "no spelling fixes
unless they're end-user-visible" policy.  That means I'll take spelling
fixes only if they're in printks or in Documentation/*.  This is a little
defense mechanism to avoid getting buried in micropatches.

I'd suggest that you find out if Adrian is still running the trivial tree
and if so, patchbomb him.
