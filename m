From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH][V2] flow dissector: check if arp_eth is null rather
 than arp
Date: Fri, 13 Jan 2017 11:02:25 -0800
Message-ID: <1484334145.13165.49.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170113184820.823-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Alexander Duyck <aduyck@mirantis.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <edumazet@google.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Simon Horman <simon.horman@netronome.com>,
        Gao Feng <fgao@ikuai8.com>, Amir Vadai <amir@vadai.me>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170113184820.823-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-01-13 at 18:48 +0000, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> arp is being checked instead of arp_eth to see if the call to
> __skb_header_pointer failed. Fix this by checking arp_eth is
> null instead of arp.   Also fix to use length hlen rather than
> hlen - sizeof(_arp); thanks to Eric Dumazet for spotting
> this latter issue.
> 
> CoverityScan CID#1396428 ("Logically dead code") on 2nd
> arp comparison (which should be arp_eth instead).
> 
> Fixes: commit 55733350e5e8b70c5 ("flow disector: ARP support")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
