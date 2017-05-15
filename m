From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH] usbnet: no address filtering on RNDIS
Date: Mon, 15 May 2017 17:08:22 +0200
Message-ID: <1494860902.2346.0.camel@suse.com>
References: <20170515115853.32688-1-oneukum@suse.com>
         <87efvqia63.fsf@miraculix.mork.no>
         <20170515.101658.471352019262168789.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:49574 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S934555AbdEOPJx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 15 May 2017 11:09:53 -0400
In-Reply-To: <20170515.101658.471352019262168789.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Montag, den 15.05.2017, 10:16 -0400 schrieb David Miller:
> From: Bjørn Mork <bjorn@mork.no>
> Date: Mon, 15 May 2017 14:20:20 +0200
> 
> > Oliver Neukum <oneukum@suse.com> writes:
> > 
> >> RNDIS does not do multicast filtering and the commands crash a few devices.
> >> Make it conditional.
> > 
> > 
> > Strange.  I thought we already discussed this when the filter reset
> > request was initially added 3 years ago.  Ref
> > https://patchwork.ozlabs.org/patch/374137/
> 
> I think the suggestion at the end of that thread is a better way to
> handle this.

Indeed. I will redo the patch.

	Regards
		Oliver
