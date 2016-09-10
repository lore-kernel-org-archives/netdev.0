From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: x25: remove null checks on arrays calling_ae and
 called_ae
Date: Fri, 09 Sep 2016 18:15:36 -0700 (PDT)
Message-ID: <20160909.181536.1766927673226492239.davem@davemloft.net>
References: <20160908074206.13662-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew.hendry@gmail.com, linux-x25@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160908074206.13662-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Thu,  8 Sep 2016 08:42:06 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> dtefacs.calling_ae and called_ae are both 20 element __u8 arrays and
> cannot be null and hence are redundant checks. Remove these.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Indeed, and if they were pointers they would be in userspace and would
need proper uaccess handling.

Applied to net-next, thanks.
