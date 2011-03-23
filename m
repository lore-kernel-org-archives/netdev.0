From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCH v2 08/16] mlx4_en: Reporting HW revision in ethtool -i
Date: Wed, 23 Mar 2011 15:46:45 +0000
Message-ID: <1300895205.2638.0.camel@bwh-desktop>
References: <4D89B16F.4040008@mellanox.co.il>
	 <1300889054.26693.527.camel@localhost>
	 <953B660C027164448AE903364AC447D20705BE28@mtldag01.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eugenia Emantayev <eugenia@mellanox.co.il>
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:17773 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755832Ab1CWPrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 11:47:06 -0400
In-Reply-To: <953B660C027164448AE903364AC447D20705BE28@mtldag01.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-03-23 at 15:10 +0000, Yevgeny Petrilin wrote:
> > 
> > This is an abuse of the ethtool_drvinfo::driver field.
> > 
> > Your users can use lspci -v, can't they?
> > 
> I don't think there is a problem here.
> We have always reported the HW model via Ethtool, we just expanded the information
> we provide.
> Our users prefer to see the information in ethtool.

Do you mean 'we documented ethtool -i as the way to get hardware
identification'?  That would be a bug in your documentation.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

