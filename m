From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: Deinline rate_control_rate_init,
 rate_control_rate_update
Date: Fri, 17 Jul 2015 15:50:22 +0200
Message-ID: <1437141022.1933.26.camel@sipsolutions.net>
References: <1436964966-2441-1-git-send-email-dvlasenk@redhat.com>
	 <1436964966-2441-2-git-send-email-dvlasenk@redhat.com>
	 (sfid-20150715_145648_616165_75545060)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michal Kazior <michal.kazior@tieto.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Denys Vlasenko <dvlasenk@redhat.com>,
	John Linville <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1436964966-2441-2-git-send-email-dvlasenk@redhat.com> (sfid-20150715_145648_616165_75545060)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-07-15 at 14:56 +0200, Denys Vlasenko wrote:
> With this .config: http://busybox.net/~vda/kernel_config,
> after deinlining these functions have sizes and callsite counts
> as follows:
> 
> rate_control_rate_init: 554 bytes, 8 calls
> rate_control_rate_update: 1596 bytes, 5 calls
> 
> Total size reduction: about 11 kbytes.
> 
Both applied.

johannes
