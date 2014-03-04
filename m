From: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Subject: RE: [PATCH v3 net-next 1/2] ethtool: Support for configurable RSS
 hash key
Date: Tue, 4 Mar 2014 10:53:57 +0000
Message-ID: <BF3270C86E8B1349A26C34E4EC1C44CB2C88806E@CMEXMB1.ad.emulex.com>
References: <1393589141-10597-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
	<0e1d7b54-dcbd-446d-b1c9-644086da138f@CMEXHTCAS2.ad.emulex.com>
 <20140303.151946.537238190479739067.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:51792 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932086AbaCDKx6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 05:53:58 -0500
In-Reply-To: <20140303.151946.537238190479739067.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >   *	Returns a negative error code or zero.
> >   * @set_rxfh_indir: Set the contents of the RX flow hash indirection table.
> >   *	Will not be called if @get_rxfh_indir_size returns zero.
> > + * @set_rxfh: Set the contents of the RX flow hash indirection table and
> > + *	hash key.
> > + *	Will not be called if @get_rxfh_indir_size and @get_rxfh_key_size
> > + *	returns zero.
>  ...
> > +	if (!(dev->ethtool_ops->get_rxfh_indir_size ||
> > +	      dev->ethtool_ops->get_rxfh_key_size ||
> > +	      dev->ethtool_ops->get_rxfh))
> > +		return -EOPNOTSUPP;
> 
> This may be just my taste but I prefer it if all the operations have to be non-
> NULL to support the new feature.  The code is so much easier to validate that
> way.

The intention was to have zero changes to the existing drivers those support indirection table configuration.
> 
> Even if you have to make generic "ethtool_get_rxfh_indir_size_zero"
> etc. routines that implementations hook up if they don't support the particular
> aspect, I prefer that to "NULL means this".
> 
> Could you make this change and resubmit?
I can make the proposed changes. Shall I submit all the NIC drivers patches as part of this patchset?
