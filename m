From: David Miller <davem@davemloft.net>
Subject: Re: stmmac ethernet in kernel 4.4: coalescing related pauses?
Date: Mon, 28 Nov 2016 09:54:31 -0500 (EST)
Message-ID: <20161128.095431.856183735501262965.davem@davemloft.net>
References: <20161123105125.GA26394@amd>
        <f14255ee-7fa8-afef-23ec-fc4f9a74eec8@marvell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pavel@ucw.cz, peppe.cavallaro@st.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: lsanfil@marvell.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f14255ee-7fa8-afef-23ec-fc4f9a74eec8@marvell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lino Sanfilippo <lsanfil@marvell.com>
Date: Mon, 28 Nov 2016 14:07:51 +0100

> Calling skb_orphan() in the xmit handler made this issue disappear.

This is not the way to handle this problem.

The solution is to free the SKBs in a timely manner after the
chip has transmitted the frame.
