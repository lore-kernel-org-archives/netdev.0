From: "Zou, Yi" <yi.zou@intel.com>
Subject: RE: [net 2/2] net: fix a bug of dropping FCoE frames when disabling
 tx ip checksum
Date: Wed, 14 Mar 2012 22:04:06 +0000
Message-ID: <138EA028228D124A900F5E6746F3C2160F6B5377@ORSMSX102.amr.corp.intel.com>
References: <1331708518-28120-2-git-send-email-jeffrey.t.kirsher@intel.com>
	<1331757355.2564.31.camel@bwh-desktop.uk.solarflarecom.com>
	<138EA028228D124A900F5E6746F3C2160F6B3176@ORSMSX102.amr.corp.intel.com>
 <20120314.145329.240390897242258725.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:17267 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030943Ab2CNWEM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 18:04:12 -0400
In-Reply-To: <20120314.145329.240390897242258725.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> From: "Zou, Yi" <yi.zou@intel.com>
> Date: Wed, 14 Mar 2012 20:48:03 +0000
> 
> > CHECKSUM_UNNECESSARY sounds good to me, if it's ok to be used on the tx
> path 
> > as well, I think so but I am not 100% sure, it'd resolve this for fcoe
> and sctp
> > like, downside is it's a bigger change that requires corresponding
> changes in
> > these protocol driver stacks as well.
> 
> This is definitely the way this bug should be fixed, CHECKSUM_PARTIAL should
> never be set for packets outside of the domain that value was designed for.

Cool, then please drop this patch and I will fix this by changing the fcoe 
protocol stack driver to use CHECKSUM_UNNECESSARY instead.

yi
