From: Andrew Morton <akpm@osdl.org>
Subject: Re: FW: + qla3xxx-is-bust.patch added to -mm tree
Date: Wed, 28 Jun 2006 16:24:00 -0700
Message-ID: <20060628162400.4e7b73ac.akpm@osdl.org>
References: <0BB3E5E7462EEA4295BC02D49691DC07176D31@AVEXCH1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linux-Driver@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:20934 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751764AbWF1XUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2006 19:20:48 -0400
To: "Ron Mercer" <ron.mercer@qlogic.com>
In-Reply-To: <0BB3E5E7462EEA4295BC02D49691DC07176D31@AVEXCH1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Ron Mercer" <ron.mercer@qlogic.com> wrote:
>
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
> I am working on the remaining items that Jeff pointed out when he
> reviewed my driver.  I will forward a patch built against what you
> currently have when I'm done.

OK.

> Now that the driver is in mm tree, is there anything I need to do to get
> it into Linus' tree?

It should go via Jeff.  I added it to -mm just to get it a bit of
attention, more reviewers, extra compile coverage testing, etc.

If you want to consider the patch in -mm to be the reference copy then
that's fine.  You should do maintenance work against that patch and I'll
add it to the patches which I send to Jeff on Thursdays until he merges it
or rejects it.
