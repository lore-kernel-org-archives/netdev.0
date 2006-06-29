From: Doug Maxey <dwm@enoyolf.org>
Subject: Re: FW: + qla3xxx-is-bust.patch added to -mm tree
Date: Wed, 28 Jun 2006 22:41:56 -0500
Message-ID: <20060629034156.567594@bebe.enoyolf.org>
References: <0BB3E5E7462EEA4295BC02D49691DC07176D31@AVEXCH1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Andrew Morton" <akpm@osdl.org>, netdev@vger.kernel.org,
	"Linux Driver" <Linux-Driver@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from falcon30.maxeymade.com ([24.173.215.190]:11990 "EHLO
	bebe.enoyolf.org") by vger.kernel.org with ESMTP id S932110AbWF2DmL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 23:42:11 -0400
In-reply-to: <0BB3E5E7462EEA4295BC02D49691DC07176D31@AVEXCH1.qlogic.org>
To: "Ron Mercer" <ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wed, 28 Jun 2006 16:07:22 PDT, "Ron Mercer" wrote:
> > 
> > Is the device hotpluggable?   If so, this:
> > 
> > 	qdev->index = cards_found;
> > 
> > in the probe() handler might do odd things - it'll just keep 
> > increasing as the card is removed and re-added.
> > 
> > iirc, that's a common problem with net drivers.  AFAICT it'll 
> > cause only cosmetic oddities here.
> > 
> >
> 
> Not sure if the device supports hotplug.  I'm looking into it.  Either
> way, I will be removing qdev->index.  It's not needed. 
> 

Oh indeed it will on System p, the new name for the power series.

Both it and the qla4xxx on a single adapter can (and will) be moved
between partitions, preceded by a hot-unplug in the DLPAR environment.

++doug

