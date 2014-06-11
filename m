From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_vti: fix sparse warnings for VTI_ISVTI
Date: Wed, 11 Jun 2014 15:41:02 -0700 (PDT)
Message-ID: <20140611.154102.358172856037880938.davem@davemloft.net>
References: <20140611150914.c3cb48bb8a1a760564f5db6e@qrator.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, trivial@kernel.org
To: ixaphire@qrator.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140611150914.c3cb48bb8a1a760564f5db6e@qrator.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dmitry Popov <ixaphire@qrator.net>
Date: Wed, 11 Jun 2014 15:09:14 +0400

> This patch fixes the following sparse warnings:
> 
> net/ipv4/ip_tunnel.c:245:53: warning: restricted __be16 degrades to integer
> net/ipv4/ip_vti.c:321:19: warning: incorrect type in assignment (different base types)
> net/ipv4/ip_vti.c:321:19:    expected restricted __be16 [addressable] [assigned] [usertype] i_flags
> net/ipv4/ip_vti.c:321:19:    got int
> net/ipv4/ip_vti.c:447:24: warning: incorrect type in assignment (different base types)
> net/ipv4/ip_vti.c:447:24:    expected restricted __be16 [usertype] i_flags
> net/ipv4/ip_vti.c:447:24:    got int
> 
> Since VTI_ISVTI is always used with ip_tunnel_parm->i_flags (which is __be16),
> we can __force cast VTI_ISVTI to __be16 in header file.
> 
> Signed-off-by: Dmitry Popov <ixaphire@qrator.net>

Applied.
