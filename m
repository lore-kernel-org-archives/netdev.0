From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4] udp reuseport: fix packet of same flow hashed to
 different socket
Date: Sun, 12 Jun 2016 20:13:31 -0700
Message-ID: <1465787611.7945.142.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1465786970-10157-1-git-send-email-suxm@chinanetcenter.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: Su Xuemin <suxm@chinanetcenter.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34015 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933130AbcFMDNf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2016 23:13:35 -0400
In-Reply-To: <1465786970-10157-1-git-send-email-suxm@chinanetcenter.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-06-13 at 11:02 +0800, Su Xuemin wrote:
> From: "Su, Xuemin" <suxm@chinanetcenter.com>
> 
> There is a corner case in which udp packets belonging to a same
> flow are hashed to different socket when hslot->count changes from 10
> to 11:
...
> Signed-off-by: Su, Xuemin <suxm@chinanetcenter.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
> I use this tree to generate the patch:
>   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
> 
>  net/ipv4/udp.c | 73 +++++++++++++---------------------------------------------
>  net/ipv6/udp.c | 71 +++++++++++++-------------------------------------------
>  2 files changed, 32 insertions(+), 112 deletions(-)

Very nice simplification of UDP stack, thanks a lot for finalizing this.
