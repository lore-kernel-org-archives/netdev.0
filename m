From: Florian Reitmeir <florian@reitmeir.org>
Subject: Re: [PATCH 06/21] e1000: add smart power down code
Date: Tue, 27 Jun 2006 10:49:08 +0200
Message-ID: <20060627084908.GA29018@squat.noreply.org>
References: <20060622051815.25497.89192.stgit@gitlost.site> <20060622052018.25497.43884.stgit@gitlost.site> <44A08D35.7090007@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <netdev-owner@vger.kernel.org>
Received: from opium.multi24.com ([213.239.202.166]:37101 "EHLO
	opium.multi24.com") by vger.kernel.org with ESMTP id S1751301AbWF0ItJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 04:49:09 -0400
To: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <44A08D35.7090007@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 26 Jun 2006, Jeff Garzik wrote:

> Kok, Auke wrote:
> >Smart Power Down is a power saving feature in newer e1000 hardware. We
> >disable it because it causes time to link to be long, but make it a
> >user choice.
> >
> >Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> >Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> >---
> >
> > drivers/net/e1000/e1000.h       |    1 +
> > drivers/net/e1000/e1000_main.c  |   15 +++++++++++++++
> > drivers/net/e1000/e1000_param.c |   25 +++++++++++++++++++++++++
> > 3 files changed, 41 insertions(+), 0 deletions(-)
> 
> Since it's not default, who will actually use this?  Particularly since 
> it is only a module option, and not supported through ethtool (frown).
i would use it, i always wanted the feature on my laptop (ibm thinkpad)

-- 
Florian Reitmeir
