From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: fix order of flag descriptions
Date: Fri, 18 Mar 2016 17:49:16 +0100
Message-ID: <1458319756.13729.1.camel@sipsolutions.net>
References: <1458317369-28185-1-git-send-email-luisbg@osg.samsung.com>
	 <1458318955-32070-1-git-send-email-luisbg@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Luis de Bethencourt <luisbg@osg.samsung.com>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458318955-32070-1-git-send-email-luisbg@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-03-18 at 16:35 +0000, Luis de Bethencourt wrote:
> Fix order of mac80211_rx_flags description to match the enum.
> 
> Signed-off-by: Luis de Bethencourt <luisbg@osg.samsung.com>
> ---
> Hi,
> 
> I want ahead and fixed the order of the descriptions. checkpatch.pl
> was giving
> a warning to my previous patch and I had a hunch it was because the
> wrong order
> breaks the parser. Indeed it does and with this patch below
> checkpatch.pl does
> not complain about this flag descriptions anymore.
> 
Huh. I think we should fix checkpatch.pl instead. While the current
order isn't likely really good, I believe kernel-doc will output the
documentation in the order it's listed, and that can be useful for the
documentation output to group related things, even if their bits may be
further apart.

johannes
