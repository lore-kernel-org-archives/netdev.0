From: James Bottomley <James.Bottomley@suse.de>
Subject: Re: [linux-pm] [PATCH 3/3] pm_qos: get rid of the allocation in
 pm_qos_add_request()
Date: Thu, 01 Jul 2010 17:30:39 -0500
Message-ID: <1278023439.2813.388.camel@mulgrave.site>
References: <1277746434.10879.191.camel@mulgrave.site>
	 <1277747088.10879.201.camel@mulgrave.site> <20100629043954.GB6250@gvim.org>
	 <201007020023.13815.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-pm@lists.linux-foundation.org, markgross@thegnar.org,
	Takashi Iwai <tiwai@suse.de>, netdev@vger.kernel.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:37136 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753981Ab0GAWaq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jul 2010 18:30:46 -0400
In-Reply-To: <201007020023.13815.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-07-02 at 00:23 +0200, Rafael J. Wysocki wrote:
> I would apply this one too, but I need a final changelog for it.  Care to send?

How about:

All current users of pm_qos_add_request() have the ability to supply the
memory required by the pm_qos routines, so make them do this and
eliminate the kmalloc() with pm_qos_add_request().  This has the double
benefit of making the call never fail and allowing it to be called from
atomic context.

+ signoffs

James


