From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net-next 2/3] cxgb4/cxgb4vf: Add set VF mac address
 support
Date: Thu, 30 Jun 2016 13:13:15 +0000
Message-ID: <CO2PR11MB00888D6B7361F0F7ECCF861597240@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1467284449-28499-1-git-send-email-hariprasad@chelsio.com>
 <1467284449-28499-3-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	"leedom@chelsio.com" <leedom@chelsio.com>,
	"nirranjan@chelsio.com" <nirranjan@chelsio.com>,
	"kumaras@chelsio.com" <kumaras@chelsio.com>
To: Hariprasad Shenai <hariprasad@chelsio.com>,
	David Miller <davem@davemloft.net>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0143.outbound.protection.outlook.com ([207.46.100.143]:36394
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751997AbcF3NNT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 09:13:19 -0400
In-Reply-To: <1467284449-28499-3-git-send-email-hariprasad@chelsio.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +	/* verify MAC addr is valid */
> +	if (!is_zero_ether_addr(mac) && !is_valid_ether_addr(mac) &&
> +	    is_multicast_ether_addr(mac)) {

This is really odd as verification goes; Currently this is a very elaborate
way of checking for multicast, but I guess it's  probably a mistake.
