From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [linux-pm] [PATCH 3/3] pm_qos: get rid of the allocation in pm_qos_add_request()
Date: Fri, 2 Jul 2010 00:23:13 +0200
Message-ID: <201007020023.13815.rjw@sisk.pl>
References: <1277746434.10879.191.camel@mulgrave.site> <1277747088.10879.201.camel@mulgrave.site> <20100629043954.GB6250@gvim.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-pm@lists.linux-foundation.org, markgross@thegnar.org,
	Takashi Iwai <tiwai@suse.de>, netdev@vger.kernel.org
To: James Bottomley <James.Bottomley@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:42892 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932199Ab0GAWYf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jul 2010 18:24:35 -0400
In-Reply-To: <20100629043954.GB6250@gvim.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, June 29, 2010, mark gross wrote:
> On Mon, Jun 28, 2010 at 12:44:48PM -0500, James Bottomley wrote:
> > Since every caller has to squirrel away the returned pointer anyway,
> > they might as well supply the memory area.  This fixes a bug in a few of
> > the call sites where the returned pointer was dereferenced without
> > checking it for NULL (which gets returned if the kzalloc failed).
> > 
> > I'd like to hear how sound and netdev feels about this: it will add
> > about two more pointers worth of data to struct netdev and struct
> > snd_pcm_substream .. but I think it's worth it.  If you're OK, I'll add
> > your acks and send through the pm tree.
> > 
> > This also looks to me like an android independent clean up (even though
> > it renders the request_add atomically callable).  I also added include
> > guards to include/linux/pm_qos_params.h
> > 
> > cc: netdev@vger.kernel.org
> > cc: Takashi Iwai <tiwai@suse.de>
> > Signed-off-by: James Bottomley <James.Bottomley@suse.de>
> Thank you for doing this!, I'll integrate it into some testing targets
> in the morning!
> 
> Signed-off-by: mark gross <markgross@thegnar.org>

I would apply this one too, but I need a final changelog for it.  Care to send?

Rafael
