From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/2] net: dsa: lan9303: Learn addresses on
 CPU port when bridged
Date: Fri, 27 Oct 2017 23:31:16 +0900 (KST)
Message-ID: <20171027.233116.1305727273603339304.davem@davemloft.net>
References: <20171026090049.1647-1-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: privat@egil-hjelmeland.no
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171026090049.1647-1-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Date: Thu, 26 Oct 2017 11:00:47 +0200

> When CPU transmit directly to port using tag, the LAN9303 does not
> learn MAC addresses received on the CPU port into the ALR table.
> ALR learning is performed only when transmitting using ALR lookup.
> 
> Solution:
> If the two external ports are bridged and the packet is not STP BPDU,
> then use ALR lookup to allow ALR learning on CPU port.
> Otherwise transmit directly to port with STP state override.
> 
> The first patch moves struct lan9303 to include/linux/dsa/lan9303.h in
> order to prepare for the second patch. 
> 
> Changes v1 -> v2:
>  - new file: include/linux/dsa/lan9303.h instead of include/linux/lan9303.h
>  - include linux/if_ether.h in include/linux/dsa/lan9303.h
>  - renamed lan9303_tx_use_arl to lan9303_xmit_use_arl for consistency.
>  - removed inline keyword to lan9303_xmit_use_arl

Series applied, thank you!
