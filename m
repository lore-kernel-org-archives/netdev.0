From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2/2]d80211: add hardware scan callback
Date: Tue, 29 Aug 2006 14:08:37 +0200
Message-ID: <1156853317.3788.26.camel@ux156>
References: <1156494733.21483.14.camel@devlinux-hong>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jbenc@suse.cz, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:22182 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S964968AbWH2MII
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 08:08:08 -0400
To: Hong Liu <hong.liu@intel.com>
In-Reply-To: <1156494733.21483.14.camel@devlinux-hong>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-08-25 at 16:32 +0800, Hong Liu wrote:
> 
> +       local->sta_scanning = 1;
> +       if (local->hw->hw_scan)
> +               return local->hw->hw_scan(dev, ssid, ssid_len); 

You set sta_scanning even if that returns an error, is that correct?

johannes
