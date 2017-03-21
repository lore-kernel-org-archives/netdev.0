From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8152: fix the list rx_done may be used without
 initialization
Date: Tue, 21 Mar 2017 14:37:29 -0700 (PDT)
Message-ID: <20170321.143729.15606239118290633.davem@davemloft.net>
References: <20170313215714.n2p6j4nxtpxbheaj@dell5510>
        <1394712342-15778-252-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, petr.vorel@gmail.com, nic_swsd@realtek.com,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-252-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Tue, 14 Mar 2017 14:15:20 +0800

> The list rx_done would be initialized when the linking on occurs.
> Therefore, if a napi is scheduled without any linking on before,
> the following kernel panic would happen.
> 
> 	BUG: unable to handle kernel NULL pointer dereference at 000000000000008
> 	IP: [<ffffffffc085efde>] r8152_poll+0xe1e/0x1210 [r8152]
> 	PGD 0
> 	Oops: 0002 [#1] SMP
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied.
