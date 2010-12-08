From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: (Lack of) specification for RX n-tuple filtering
Date: Wed, 08 Dec 2010 19:14:41 +0000
Message-ID: <1291835681.2560.53.camel@bwh-desktop>
References: <1279832544.2104.63.camel@achroite.uk.solarflarecom.com>
	 <4C48BD1A.4060409@chelsio.com>
	 <1283870637.2270.10.camel@achroite.uk.solarflarecom.com>
	 <1291825443.31064.193.camel@lb-tlvb-vladz>
	 <1291828940.2560.17.camel@bwh-desktop>
	 <1291833578.17102.69.camel@lb-tlvb-vladz>
	 <1291834931.2560.42.camel@bwh-desktop>
	 <1291835453.24019.13.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dimitris Michailidis <dm@chelsio.com>,
	Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Vladislav Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:49592 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755859Ab0LHTOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 14:14:46 -0500
In-Reply-To: <1291835453.24019.13.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-12-08 at 21:10 +0200, Vladislav Zolotarov wrote:
> > The implementation of the -U
> > option could potentially be made to fallback to ETHTOOL_SRXCLSRLINS if
> > vlan_tag and user_def are not specified.
> > 
> 
> Having said that, don't u think that it could be more user friendly to
> extend the ETHTOOL_SRXCLSRLINS interface to handle the lan_tag and
> user_def and drop the n-tuple interface at all?

No, we can't remove userland interfaces.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

