From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 01/14] clarify implementation of ethtool's get_ts_info
 op
Date: Fri, 17 Jul 2015 21:17:40 +0200
Message-ID: <20150717191740.GA19016@localhost.localdomain>
References: <1437143123-5031-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1437143123-5031-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Jacob Keller <jacob.e.keller@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:38727 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752216AbbGQTRq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 15:17:46 -0400
Received: by wicmv11 with SMTP id mv11so50283859wic.1
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 12:17:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1437143123-5031-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 17, 2015 at 07:25:10AM -0700, Jeff Kirsher wrote:
> From: Jacob Keller <jacob.e.keller@intel.com>
> 
> This patch adds some clarification about the intended way to implement
> both SIOCSHWTSTAMP and ethtool's get_ts_info. The HWTSTAMP API has
> several Rx filters which are very specific, as well as more general
> filters. The specific filters really only exist to support some broken
> hardware which can't fully implement the generic filters. This patch
> adds clarification that it is okay to support the specific filters in
> SIOCSHWTSTAMP by upscaling them to the generic filters. In addition,
> update the header for ethtool_ts_info to specify that drivers ought to
> only report the filters they support without upscaling in this manner.

Acked-by: Richard Cochran <richardcochran@gmail.com>

(for this patch and the other get_ts_info patches)
