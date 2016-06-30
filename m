From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: Re: [PATCH net-next 2/3] cxgb4/cxgb4vf: Add set VF mac address
 support
Date: Thu, 30 Jun 2016 20:45:11 +0530
Message-ID: <20160630151510.GA20137@hari-Latitude-E5550>
References: <1467284449-28499-1-git-send-email-hariprasad@chelsio.com>
 <1467284449-28499-3-git-send-email-hariprasad@chelsio.com>
 <CO2PR11MB00888D6B7361F0F7ECCF861597240@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	"leedom@chelsio.com" <leedom@chelsio.com>,
	"nirranjan@chelsio.com" <nirranjan@chelsio.com>,
	"kumaras@chelsio.com" <kumaras@chelsio.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [12.32.117.8] ([12.32.117.8]:15276 "EHLO
	stargate3.asicdesigners.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752511AbcF3PwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 11:52:20 -0400
Content-Disposition: inline
In-Reply-To: <CO2PR11MB00888D6B7361F0F7ECCF861597240@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 30, 2016 at 13:13:15 +0000, Yuval Mintz wrote:
> > +	/* verify MAC addr is valid */
> > +	if (!is_zero_ether_addr(mac) && !is_valid_ether_addr(mac) &&
> > +	    is_multicast_ether_addr(mac)) {
> 
> This is really odd as verification goes; Currently this is a very elaborate
> way of checking for multicast, but I guess it's  probably a mistake.
> 
My bad, will send a V2
