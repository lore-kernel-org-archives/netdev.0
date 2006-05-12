From: Pavel Roskin <proski@gnu.org>
Subject: Re: [PATCH 1/5] new pcmcia IDs for hostap - ASUS WL-110
Date: Fri, 12 May 2006 16:17:33 -0400
Message-ID: <1147465053.8478.18.camel@dv>
References: <20060512165706.GA4079@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Marcin Juszkiewicz <linux-arm@hrw.one.pl>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:14731 "EHLO
	fencepost.gnu.org") by vger.kernel.org with ESMTP id S932208AbWELUSS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 May 2006 16:18:18 -0400
Received: from proski by fencepost.gnu.org with local (Exim 4.34)
	id 1Fee5Z-00049j-0j
	for netdev@vger.kernel.org; Fri, 12 May 2006 16:18:17 -0400
To: jt@hpl.hp.com
In-Reply-To: <20060512165706.GA4079@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-05-12 at 09:57 -0700, Jean Tourrilhes wrote:
> Marcin Juszkiewicz wrote :
> > 
> > This time I checked more carefully my changeset and split it into
> > smaller parts. Few of my patches was tested by OpenZaurus users, some
> > are waiting for testing.
> 
> 	I'm sorry, but I will have again to veto part of your patch.
> 	You are removing IDs from the Orinoco driver. Please don't do
> that, those card work perfectly with the orinoco driver, and some of
> us run them with the orinoco driver (orinoco is one third the
> footprint of hostap).

Once again, I really appreciate your vigilance, Jean :-)

I strongly believe that every driver should list all devices it can
support.  In case of multiple drivers supporting one device, the choice
should be done in userspace.

-- 
Regards,
Pavel Roskin

