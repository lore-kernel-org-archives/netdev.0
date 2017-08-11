From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH][next] Bluetooth: kfree tmp rather than an alias to it
Date: Fri, 11 Aug 2017 21:20:26 +0200
Message-ID: <5F62B3BB-4288-42A6-8BD6-6E39EEAB7C58@holtmann.org>
References: <20170811183304.17580-1-colin.king@canonical.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>,
        Netdev list <netdev@vger.kernel.org>,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170811183304.17580-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Colin,

> While the kfree of dhkey_a is of the same address of tmp, it
> probably is clearer and more human readable if tmp is kfree'd
> rather than dhkey_a.
> 
> Detected by CoverityScan, CID#1448650 ("Free of address-of expression")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
> net/bluetooth/selftest.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)

patch has been applied to bluetooth-next tree.

Regards

Marcel
