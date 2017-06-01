From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] net: dsa: make function ksz_rcv static
Date: Thu, 01 Jun 2017 12:12:58 -0400 (EDT)
Message-ID: <20170601.121258.1089374239881121559.davem@davemloft.net>
References: <20170601122242.14341-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Woojung.Huh@microchip.com, UNGLinuxDriver@microchip.com,
        andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170601122242.14341-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Thu,  1 Jun 2017 13:22:42 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> function ksz_rcv can be made static as it does not need to be
> in global scope. Reformat arguments to make it checkpatch warning
> free too.
> 
> Cleans up sparse warning: "symbol 'ksz_rcv' was not declared. Should
> it be static?"
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
