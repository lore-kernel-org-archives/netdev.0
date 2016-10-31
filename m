From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net] r8152: Fix broken RX checksums.
Date: Mon, 31 Oct 2016 08:14:27 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB201047353@RTITMBSV03.realtek.com.tw>
References: <9fb6be7b-95f3-6e59-c0f4-1d6c3357416d@pobox.com>
        <20161030.205755.1198665157526465556.davem@davemloft.net>
        <1f847ae0-4928-01e7-f1e7-3cbc37529961@pobox.com>
 <20161030.235342.134481656830778556.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: nic_swsd <nic_swsd@realtek.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
        "mlord@pobox.com" <mlord@pobox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161030.235342.134481656830778556.davem@davemloft.net>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >>> The r8152 driver has been broken since (approx) 3.16.xx
> >>> when support was added for hardware RX checksums
> >>> on newer chip versions.  Symptoms include random
> >>> segfaults and silent data corruption over NFS.
> >>>
> >>> The hardware checksum logig does not work on the VER_02
> >>> dongles I have here when used with a slow embedded system CPU.
> >>> Google reveals others reporting similar issues on Raspberry Pi.
> >>>
> >>> So, disable hardware RX checksum support for VER_02, and fix
> >>> an obvious coding error for IPV6 checksums in the same function.
> >>>
> >>> Because this bug results in silent data corruption,
> >>> it is a good candidate for back-porting to -stable >= 3.16.xx.
> >>>
> >>> Signed-off-by: Mark Lord <mlord@pobox.com>
> >>
> >> Applied and queued up for -stable, thanks.
> >
> > Thanks.  Now that this is taken care of, I do wonder if perhaps
> > RX checksums ought to be enabled at all for ANY versions of this chip?
> 
> You should really start a dialogue with the developer who has been
> making the most, if not all, of the major changes to this driver over
> the past few years, Hayes Wang.

Our hw engineer says only VER_01 has the issue about rx checksum.
I need more information for checking it.

Best Regards,
Hayes
