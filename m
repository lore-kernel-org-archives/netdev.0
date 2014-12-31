From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tun: return proper error code from tun_do_read
Date: Wed, 31 Dec 2014 14:15:37 -0500 (EST)
Message-ID: <20141231.141537.1885739121180441904.davem@davemloft.net>
References: <1419578569-13132-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com
To: agartrell@fb.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419578569-13132-1-git-send-email-agartrell@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alex Gartrell <agartrell@fb.com>
Date: Thu, 25 Dec 2014 23:22:49 -0800

> Instead of -1 with EAGAIN, read on a O_NONBLOCK tun fd will return 0.  This
> fixes this by properly returning the error code from __skb_recv_datagram.
> 
> Signed-off-by: Alex Gartrell <agartrell@fb.com>

Applied.
