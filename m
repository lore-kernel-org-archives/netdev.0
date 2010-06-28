From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [linux-pm] [PATCH 3/3] pm_qos: get rid of the allocation in pm_qos_add_request()
Date: Mon, 28 Jun 2010 23:59:17 +0200
Message-ID: <201006282359.18045.rjw@sisk.pl>
References: <1277746434.10879.191.camel@mulgrave.site> <1277747088.10879.201.camel@mulgrave.site>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-pm@lists.linux-foundation.org, Takashi Iwai <tiwai@suse.de>,
	netdev@vger.kernel.org, markgross@thegnar.org
To: James Bottomley <James.Bottomley@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:57856 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753877Ab0F1WA7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jun 2010 18:00:59 -0400
In-Reply-To: <1277747088.10879.201.camel@mulgrave.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, June 28, 2010, James Bottomley wrote:
> Since every caller has to squirrel away the returned pointer anyway,
> they might as well supply the memory area.  This fixes a bug in a few of
> the call sites where the returned pointer was dereferenced without
> checking it for NULL (which gets returned if the kzalloc failed).
> 
> I'd like to hear how sound and netdev feels about this: it will add
> about two more pointers worth of data to struct netdev and struct
> snd_pcm_substream .. but I think it's worth it.  If you're OK, I'll add
> your acks and send through the pm tree.
> 
> This also looks to me like an android independent clean up (even though
> it renders the request_add atomically callable).  I also added include
> guards to include/linux/pm_qos_params.h
> 
> cc: netdev@vger.kernel.org
> cc: Takashi Iwai <tiwai@suse.de>
> Signed-off-by: James Bottomley <James.Bottomley@suse.de>

I like all of the patches in this series, thanks a lot for doing this!

I guess it might be worth sending a CC to the LKML next round so that people
can see [1/3] (I don't expect any objections, but anyway it would be nice).

Thanks,
Rafael
