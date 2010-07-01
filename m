From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [linux-pm] [PATCH 3/3] pm_qos: get rid of the allocation in pm_qos_add_request()
Date: Fri, 2 Jul 2010 00:38:20 +0200
Message-ID: <201007020038.20254.rjw@sisk.pl>
References: <1277746434.10879.191.camel@mulgrave.site> <201007020023.13815.rjw@sisk.pl> <1278023439.2813.388.camel@mulgrave.site>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-pm@lists.linux-foundation.org, markgross@thegnar.org,
	Takashi Iwai <tiwai@suse.de>, netdev@vger.kernel.org
To: James Bottomley <James.Bottomley@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:42950 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759498Ab0GAWju (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jul 2010 18:39:50 -0400
In-Reply-To: <1278023439.2813.388.camel@mulgrave.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, July 02, 2010, James Bottomley wrote:
> On Fri, 2010-07-02 at 00:23 +0200, Rafael J. Wysocki wrote:
> > I would apply this one too, but I need a final changelog for it.  Care to send?
> 
> How about:
> 
> All current users of pm_qos_add_request() have the ability to supply the
> memory required by the pm_qos routines, so make them do this and
> eliminate the kmalloc() with pm_qos_add_request().  This has the double
> benefit of making the call never fail and allowing it to be called from
> atomic context.
> 
> + signoffs

OK

I'll apply it shortly.

Rafael
