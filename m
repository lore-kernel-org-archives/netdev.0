From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] 8021q: fix a potential use-after-free
Date: Sat, 23 Mar 2013 08:16:06 -0700
Message-ID: <1364051766.4431.86.camel@edumazet-glaptop>
References: <1363938600-26129-1-git-send-email-amwang@redhat.com>
	 <1364015648-4195-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:44152 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050Ab3CWPQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Mar 2013 11:16:09 -0400
Received: by mail-pa0-f50.google.com with SMTP id bg2so372961pad.9
        for <netdev@vger.kernel.org>; Sat, 23 Mar 2013 08:16:09 -0700 (PDT)
In-Reply-To: <1364015648-4195-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-03-23 at 13:14 +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> vlan_vid_del() could possibly free ->vlan_info after a RCU grace
> period, however, we may still refer to the freed memory area
> by 'grp' pointer. Found by code inspection.
> 
> This patch moves vlan_vid_del() as behind as possible.
> 
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> ---
>  net/8021q/vlan.c |   14 +++++++-------
>  1 files changed, 7 insertions(+), 7 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
