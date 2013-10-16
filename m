From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 net 1/4] bridge: Don't use VID 0 and 4095 in vlan
 filtering
Date: Wed, 16 Oct 2013 08:47:38 -0700
Message-ID: <20131016084738.6e2eaae0@nehalam.linuxnetplumber.net>
References: <1381910836-718-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	<1381910836-718-2-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	Toshiaki Makita <toshiaki.makita1@gmail.com>
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:58559 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753790Ab3JPPrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 11:47:42 -0400
Received: by mail-pb0-f47.google.com with SMTP id rr4so983495pbb.6
        for <netdev@vger.kernel.org>; Wed, 16 Oct 2013 08:47:41 -0700 (PDT)
In-Reply-To: <1381910836-718-2-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Oct 2013 17:07:13 +0900
Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp> wrote:

> IEEE 802.1Q says that:
> - VID 0 shall not be configured as a PVID, or configured in any Filtering
> Database entry.
> - VID 4095 shall not be configured as a PVID, or transmitted in a tag
> header. This VID value may be used to indicate a wildcard match for the VID
> in management operations or Filtering Database entries.
> (See IEEE 802.1Q-2011 6.9.1 and Table 9-2)
> 
> Don't accept adding these VIDs in the vlan_filtering implementation.
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> Reviewed-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>  net/bridge/br_fdb.c     |  4 +-
>  net/bridge/br_netlink.c |  2 +-
>  net/bridge/br_vlan.c    | 97 +++++++++++++++++++++++--------------------------
>  3 files changed, 49 insertions(+), 54 deletions(-)

This one looks good, thanks.

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
