From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v2 08/16] mlx4_en: Reporting HW revision in ethtool -i
Date: Wed, 23 Mar 2011 08:58:15 -0700
Message-ID: <20110323085815.0a2cbcb0@nehalam>
References: <4D89B16F.4040008@mellanox.co.il>
	<1300889054.26693.527.camel@localhost>
	<953B660C027164448AE903364AC447D20705BE28@mtldag01.mtl.com>
	<1300895205.2638.0.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eugenia Emantayev <eugenia@mellanox.co.il>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34828 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933216Ab1CWP6V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2011 11:58:21 -0400
In-Reply-To: <1300895205.2638.0.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Mar 2011 15:46:45 +0000
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Wed, 2011-03-23 at 15:10 +0000, Yevgeny Petrilin wrote:
> > > 
> > > This is an abuse of the ethtool_drvinfo::driver field.
> > > 
> > > Your users can use lspci -v, can't they?
> > > 
> > I don't think there is a problem here.
> > We have always reported the HW model via Ethtool, we just expanded the information
> > we provide.
> > Our users prefer to see the information in ethtool.
> 
> Do you mean 'we documented ethtool -i as the way to get hardware
> identification'?  That would be a bug in your documentation.

We need consistency among drivers in these fields.
