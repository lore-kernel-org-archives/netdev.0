From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [Patch 2/2] mlx4: add dynamic LRO disable support
Date: Mon, 7 Jun 2010 13:00:38 +0200
Message-ID: <20100607130038.11581e28@dhcp-lab-109.englab.brq.redhat.com>
References: <20100603034303.5305.55552.sendpatchset@localhost.localdomain>
	<20100603034312.5305.61000.sendpatchset@localhost.localdomain>
	<1275568622.2870.89.camel@localhost>
	<4C085D45.6040001@redhat.com>
	<1275661552.2095.13.camel@achroite.uk.solarflarecom.com>
	<4C0CB325.2040704@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	herbert.xu@redhat.com, nhorman@redhat.com, davem@davemloft.net
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55077 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751424Ab0FGLA4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jun 2010 07:00:56 -0400
In-Reply-To: <4C0CB325.2040704@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 07 Jun 2010 16:51:49 +0800
Cong Wang <amwang@redhat.com> wrote:

> > Now that I look at the patch again, I see you're using a static (i.e.
> > global) variable to 'back up' the non-zero (enabled) value of num_lro.
> > This is introducing a bug!  The correct value is apparently set in
> > mlx4_en_get_profile(); you would need to replicate that.
> >
> 
> Oh, probably, but unfortunately 'num_lro' is static so only visible
> in en_main.c.

So just remove "static" and make it global :-)

Stanislaw
