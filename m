From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][V2][netdev-next] gre: remove duplicated assignment of
 iph
Date: Wed, 23 Aug 2017 22:36:17 -0700 (PDT)
Message-ID: <20170823.223617.467388957481861020.davem@davemloft.net>
References: <20170823115948.19884-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: u9012063@gmail.com, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170823115948.19884-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Wed, 23 Aug 2017 12:59:48 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> iph is being assigned the same value twice; remove the redundant
> first assignment. (Thanks to Nikolay Aleksandrov for pointing out
> that the first asssignment should be removed and not the second)
> 
> Fixes warning:
> net/ipv4/ip_gre.c:265:2: warning: Value stored to 'iph' is never read
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Much better, applied, thanks.
