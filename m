From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [RXRPC]: do not unlock unheld spinlock in
 rxrpc_connect_exclusive()
Date: Tue, 17 Dec 2013 15:16:56 -0500 (EST)
Message-ID: <20131217.151656.2218064732946772466.davem@davemloft.net>
References: <1386975369-30837-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: khoroshilov@ispras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386975369-30837-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Date: Sat, 14 Dec 2013 02:56:09 +0400

> +		_net("CONNECT EXCL old %d on TRANS %d",
> +		     conn->debug_id, conn->trans->debug_id);

Please do not add more of these ad-hoc kernel log tracing entries.

Thanks.
