From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 2/2]d80211: add hardware scan callback
Date: Wed, 30 Aug 2006 19:10:58 +0200
Message-ID: <20060830191058.14275f74@griffin.suse.cz>
References: <1156494733.21483.14.camel@devlinux-hong>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:9189 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751168AbWH3RLB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2006 13:11:01 -0400
To: Hong Liu <hong.liu@intel.com>
In-Reply-To: <1156494733.21483.14.camel@devlinux-hong>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 25 Aug 2006 16:32:13 +0800, Hong Liu wrote:
> Add hardware scan callback to support cards like ipw3945 which
> implements the scan command in firmware.

How ipw3945 performs scan? From the patch, it looks like it switches
channels (and sends probe requests) in the firmware and delivers all
received beacons and probe responses through the normal rx path to be
handled in a software MAC layer. This is really weird behaviour and
doesn't make sense to me. Why isn't channel switching left to the
software MAC as well?

> +/* set station scan completed */
> +void ieee80211_set_scan_completed(struct net_device *dev);

Why "set"? "ieee80211_scan_completed" sounds better.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
