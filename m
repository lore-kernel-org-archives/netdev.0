From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 3/7] igb: rename igb_ptp_enable to
 igb_ptp_feature_enable
Date: Tue, 03 Jun 2014 19:27:23 -0700 (PDT)
Message-ID: <20140603.192723.524325475036717233.davem@davemloft.net>
References: <1401781509-6435-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1401781509-6435-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jacob.e.keller@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50936 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752408AbaFDC1Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 22:27:24 -0400
In-Reply-To: <1401781509-6435-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue,  3 Jun 2014 00:45:05 -0700

> -static int igb_ptp_enable(struct ptp_clock_info *ptp,
> +static int igb_ptp_feature_enable(struct ptp_clock_info *ptp,
>  			  struct ptp_clock_request *rq, int on)

The argument on the second line needs to be adjusted if the location
of the openning parenthesis on the first line changes, as it does
here.
