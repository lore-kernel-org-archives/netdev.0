From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH v2.6.22-rc5] cxgb2: handle possible NULL pointer dereferencing,
 take 2
Date: Tue, 26 Jun 2007 09:24:29 -0700
Message-ID: <46813DBD.3060803@chelsio.com>
References: <a901b49a0706210553r58ea8743gc565fcca1a87b58f@mail.gmail.com><a901b49a0706210618q7c22cbe0jd6f7e052a8e05a97@mail.gmail.com><20070625153450.c5f535ca.akpm@linux-foundation.org><46804C3D.3080205@garzik.org> <20070625163015.175d15c0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	pradeep singh <pradeep.rautela@gmail.com>, trivial@kernel.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:32220 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753348AbXFZQYv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2007 12:24:51 -0400
In-Reply-To: <20070625163015.175d15c0.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
>
> On Mon, 25 Jun 2007 19:14:05 -0400
> Jeff Garzik <jeff@garzik.org> wrote:
>
> > Andrew Morton wrote:
> > > The chelsio driver is assuming that pci_device_id.driver_data has been
> > > initialised to the board index, but I am unable to locate anywhere 
> where
> > > that initialisation actually happens.
> >
> > It's hidden inside the CH_DEVICE() initializer-helper macro.
> >
>
> oic.
>
> Does this driver still have a maintainer, or is it now a "community"
> driver (giggle) ?
>

I follow the driver's changes. No new features going in anymore, and it 
has been quite stable.
The activity is low.

Cheers,
Divy

> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

