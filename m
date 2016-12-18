From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: check route protocol when deleting routes
Date: Sat, 17 Dec 2016 21:37:21 -0500 (EST)
Message-ID: <20161217.213721.2250751134919146675.davem@davemloft.net>
References: <20161216083059.251368-1-grawity@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-4
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: grawity@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161216083059.251368-1-grawity@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mantas Mikulìnas <grawity@gmail.com>
Date: Fri, 16 Dec 2016 10:30:59 +0200

> The protocol field is checked when deleting IPv4 routes, but ignored for
> IPv6, which causes problems with routing daemons accidentally deleting
> externally set routes (observed by multiple bird6 users).
> 
> This can be verified using `ip -6 route del <prefix> proto something`.
> 
> Signed-off-by: Mantas Mikulìnas <grawity@gmail.com>

Applied, thanks.
