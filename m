From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: Re: [PATCH v4] net: bnx2x: convert to hw_features
Date: Wed, 13 Apr 2011 12:36:44 +0300
Message-ID: <1302687404.6750.129.camel@lb-tlvb-vladz>
References: <20110411202630.C079D13909@rere.qmqm.pl>
 <1302610228.32697.298.camel@lb-tlvb-vladz>
 <20110412140708.GA21835@rere.qmqm.pl>
 <1302619012.6750.8.camel@lb-tlvb-vladz>
 <20110412144940.GA26043@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3365 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757966Ab1DMJg6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 05:36:58 -0400
In-Reply-To: <20110412144940.GA26043@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Hmm. I thought one, and wrote another.
> 
> Since bnx2x_parity_recover() runs with rtnl_lock(), as should
> netdev_update_features(), then in case the recovery is in progress
> it should be enough to not call bnx2x_reload_if_running() then
> and just change the flags --- changes will be picked up on bnx2x_nic_load()
> after recovery is complete. This removes the need for netdev_update_features()
> calls.
> 

Ok. I see what u meant in v5... ;) 
The patch is great. Thanks for your work. There are some enhancements
following your patch that I have in mind that I'll submit later.

thanks again, Michal.


