From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [patch] d80211: fix key access race
Date: Mon, 6 Nov 2006 21:23:39 +0100
Message-ID: <20061106212339.6ee81793@griffin.suse.cz>
References: <1162525702.1726.10.camel@devlinux-hong>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:35476 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1753559AbWKFUXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Nov 2006 15:23:46 -0500
To: Hong Liu <hong.liu@intel.com>
In-Reply-To: <1162525702.1726.10.camel@devlinux-hong>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 03 Nov 2006 11:48:22 +0800, Hong Liu wrote:
> It seems we don't have any protection when accessing the key.
> The RX/TX path may acquire a key which can be freed by the
> ioctl cmd.
> 
> I put a key_lock spinlock to protect all the accesses to the key
> (whether the sta_info->key or ieee80211_sub_if_data->keys[]). 
> Don't find a good way to handle it :(

NAK, this is too expensive.

I'm aware of the problem and figured how to fix it correctly while
working on fixing of sta_list locking. Will send a patch later this
week, stay tuned :-)

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
