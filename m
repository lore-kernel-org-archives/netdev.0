From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sit tunnels: propagate IPv6 transport class to IPv4
 Type of Service
Date: Tue, 16 Aug 2011 16:30:36 -0700 (PDT)
Message-ID: <20110816.163036.838746426835627017.davem@davemloft.net>
References: <20110814000438.GA30127@capsaicin.mamane.lu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: lionel@mamane.lu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110814000438.GA30127@capsaicin.mamane.lu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lionel Elie Mamane <lionel@mamane.lu>
Date: Sun, 14 Aug 2011 02:04:38 +0200

> sit tunnels (IPv6 tunnel over IPv4) do not implement the "tos inherit"
> case to copy the IPv6 transport class byte from the inner packet to
> the IPv4 type of service byte in the outer packet. By contrast, ipip
> tunnels and GRE tunnels do.
> 
> This patch, adapted from the similar code in net/ipv4/ipip.c and
> net/ipv4/ip_gre.c, implements that.
> 
> This patch applies to 3.0.1, and has been tested on that version.
> 
> 
> Signed-off-by: Lionel Elie Mamane <lionel@mamane.lu>

Applied, thanks.
