From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2/2]d80211: add hardware scan callback
Date: Fri, 01 Sep 2006 08:41:03 +0200
Message-ID: <1157092863.2878.13.camel@ux156>
References: <1156494733.21483.14.camel@devlinux-hong>
	 <20060830191058.14275f74@griffin.suse.cz>
	 <1157081867.11040.41.camel@devlinux-hong>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:45448 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751213AbWIAGkf
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 02:40:35 -0400
To: Hong Liu <hong.liu@intel.com>
In-Reply-To: <1157081867.11040.41.camel@devlinux-hong>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-09-01 at 11:37 +0800, Hong Liu wrote:
>  
> +	local->sta_scanning = 1;
> +	if (local->hw->hw_scan)
> +		return local->hw->hw_scan(dev, ssid, ssid_len);
> +

My question still stands, is it proper to assign sta_scanning to 1 even
if the function returns an error?

johannes
