From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net 0/3] bridge: Fix undesirable behavior related to vlan
Date: Wed, 13 Nov 2013 22:14:06 -0500
Message-ID: <52843FFE.7070202@redhat.com>
References: <1384331175-4136-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	"David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5295 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752609Ab3KNDON (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Nov 2013 22:14:13 -0500
In-Reply-To: <1384331175-4136-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/13/2013 03:26 AM, Toshiaki Makita wrote:
> There seem to be some problems around vlan code.
>
> - Unexpectedly filter vlan by NIC.
> - Not correctly decrement refcount of vlan_vid_info.
> - Memory leak when deleting a bridge with vlan_info allocated.
>
> This is a patch series to fix these issues.
>
> Toshiaki Makita (3):
>    bridge: Use vlan_vid_[add/del] instead of direct
>      ndo_vlan_rx_[add/kill]_vid calls
>    bridge: Call vlan_vid_del for all vids at nbp_vlan_flush
>    bridge: Fix memory leak when deleting bridge with vlan filtering
>      enabled
>

These all look good to me.  Thanks you.

Acked-by: Vlad Yasevich <vyasevic@redhat.com>

-vlad

>   net/bridge/br_if.c   |  1 +
>   net/bridge/br_vlan.c | 24 ++++++++++--------------
>   2 files changed, 11 insertions(+), 14 deletions(-)
>
