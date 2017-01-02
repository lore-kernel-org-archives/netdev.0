From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Update pptp handling to avoid null pointer deref. v2
Date: Mon, 02 Jan 2017 12:54:35 -0500 (EST)
Message-ID: <20170102.125435.819704695171565389.davem@davemloft.net>
References: <20170101231936.5905-1-ian.kumlien@gmail.com>
        <20170102081835.25557-1-ian.kumlien@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        stable@vger.kernel.org
To: ian.kumlien@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170102081835.25557-1-ian.kumlien@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ian Kumlien <ian.kumlien@gmail.com>
Date: Mon,  2 Jan 2017 09:18:35 +0100

> __skb_flow_dissect can be called with a skb or a data packet, either
> can be NULL. All calls seems to have been moved to __skb_header_pointer
> except the pptp handling which is still calling skb_header_pointer.
 ...
> Fixes: ab10dccb1160 ("rps: Inspect PPTP encapsulated by GRE to get flow hash")
> Signed-off-by: Ian Kumlien <ian.kumlien@gmail.com>

Applied and queued up for -stable.
