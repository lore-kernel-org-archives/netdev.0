From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] qed: Utilize FW 8.20.0.0
Date: Thu, 18 May 2017 10:34:28 -0400 (EDT)
Message-ID: <20170518.103428.1194147893495615244.davem@davemloft.net>
References: <1495049920-22782-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
        Chad.Dupuis@cavium.com, Ram.Amrani@cavium.com,
        Tomer.Tayar@cavium.com, Manish.Rangankar@cavium.com
To: Yuval.Mintz@cavium.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1495049920-22782-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Wed, 17 May 2017 22:38:40 +0300

> This pushes qed [and as result, all qed* drivers] into using 8.20.0.0
> firmware. The changes are mostly contained in qed with minor changes
> to qedi due to some HSI changes.
> 
> Content-wise, the firmware contains fixes to various issues exposed
> since the release of the previous firmware, including:
>  - Corrects iSCSI fast retransmit when data digest is enabled.
>  - Stop draining packets when receiving several consecutive PFCs.
>  - Prevent possible assertion when consecutively opening/closing
>    many connections.
>  - Prevent possible assertion due to too long BDQ fetch time.
> 
> In addition, the new firmware would allow us to later add iWARP support
> in qed and qedr.
> 
> Signed-off-by: Chad Dupuis <Chad.Dupuis@cavium.com>
> Signed-off-by: Ram Amrani <Ram.Amrani@cavium.com>
> Signed-off-by: Tomer Tayar <Tomer.Tayar@cavium.com>
> Signed-off-by: Manish Rangankar <Manish.Rangankar@cavium.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>

Applied.
