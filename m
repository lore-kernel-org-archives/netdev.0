From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] [PATCH] ax88179_178a: Correct the RX error
 definition in RX header
Date: Mon, 21 Oct 2013 18:55:07 -0400 (EDT)
Message-ID: <20131021.185507.288415528648852269.davem@davemloft.net>
References: <1382337460-2036-1-git-send-email-freddy@asix.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, louis@asix.com.tw, allan@asix.com.tw
To: freddy@asix.com.tw
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382337460-2036-1-git-send-email-freddy@asix.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: freddy@asix.com.tw
Date: Mon, 21 Oct 2013 14:37:40 +0800

> From: Freddy Xin <freddy@asix.com.tw>
> 
> Correct the definition of AX_RXHDR_CRC_ERR and
> AX_RXHDR_DROP_ERR. They are BIT29 and BIT31 in pkt_hdr
> seperately.
> Add VID:DID for Samsung USB Ethernet Adapter.
> 
> Signed-off-by: Freddy Xin <freddy@asix.com.tw>

Do not do two logically different things in one patch.

Fix the register bit definitions in one patch, then add the
new device IDs in another.
