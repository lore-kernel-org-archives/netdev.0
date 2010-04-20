From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: IPv6: race condition in __ipv6_ifa_notify() and dst_free() ?
Date: Tue, 20 Apr 2010 23:35:55 +0200
Message-ID: <20100420213554.GB15354@smudla-wifi.bakulak.kosire.czf>
References: <20100420174401.GB1334@midget.suse.cz>
 <1271786247.7895.130.camel@edumazet-laptop>
 <20100420204939.GA15354@smudla-wifi.bakulak.kosire.czf>
 <1271797043.7895.320.camel@edumazet-laptop>
 <20100420141655.3a66b8e8@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Jiri Bohac <jbohac@suse.cz>,
	netdev@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:34330 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755485Ab0DTVfY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Apr 2010 17:35:24 -0400
Content-Disposition: inline
In-Reply-To: <20100420141655.3a66b8e8@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 20, 2010 at 02:16:55PM -0700, Stephen Hemminger wrote:
> Is this problem new to net-next where we hold onto addresses, or was
> the issue there before?

Before. I am seeing it on 2.6.32.

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

