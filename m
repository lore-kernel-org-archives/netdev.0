From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] cls_cgroup: get sk_classid only from full sockets
Date: Mon, 18 Apr 2016 05:14:48 -0700
Message-ID: <1460981688.10638.103.camel@edumazet-glaptop3.roam.corp.google.com>
References: <146097943086.15300.8997345346172526153.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146097943086.15300.8997345346172526153.stgit@buzz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-04-18 at 14:37 +0300, Konstantin Khlebnikov wrote:
> skb->sk could point to timewait or request socket which has no sk_classid.
> Detected as "BUG: KASAN: slab-out-of-bounds in cls_cgroup_classify".
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
