From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH][net-next] ipv6: fix dereference of rt6_ex before null
 check error
Date: Tue, 10 Oct 2017 10:26:10 -0700
Message-ID: <1507656370.31614.18.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171010170116.21124-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171010170116.21124-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-10-10 at 18:01 +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> Currently rt6_ex is being dereferenced before it is null checked
> hence there is a possible null dereference bug. Fix this by only
> dereferencing rt6_ex after it has been null checked.
> 
> Detected by CoverityScan, CID#1457749 ("Dereference before null check")
> 
> Fixes: 81eb8447daae ("ipv6: take care of rt6_stats")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---

Reviewed-by: Eric Dumazet <edumazet@google.com>
