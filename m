From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH 3/3] chelsio: more rx speedup
Date: Wed, 10 Jan 2007 09:30:12 +0100
Message-ID: <200701100930.12798.netdev@axxeo.de>
References: <20061215190716.956791000@osdl.org> <200701090942.04197.netdev@axxeo.de> <20070109102647.05d92861@freekitty>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:60775 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932742AbXAJIaa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jan 2007 03:30:30 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20070109102647.05d92861@freekitty>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger schrieb:
> On Tue, 9 Jan 2007 09:42:03 +0100
> Ingo Oeser <netdev@axxeo.de> wrote:
> > Stephen Hemminger schrieb:
> > > --- netdev-2.6.orig/drivers/net/chelsio/sge.c
> > > +++ netdev-2.6/drivers/net/chelsio/sge.c
> > Please use NET_IP_ALIGN here:
> 
> Wrong, NET_IP_ALIGN is intended to deal with platforms where alignment of DMA is more
> important of alignment of structures.  Therefore if data is copied, it should
> always be 2.

Ah! Thanks for clearing this up. These magic numbers always make my head spin
so I tried to come up with sth. useful :-)

If this pattern is present in many drivers, we might have a define or helper for this.


Regards

Ingo Oeser
