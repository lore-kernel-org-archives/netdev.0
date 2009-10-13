From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] udp: Fix udp_poll() and ioctl()
Date: Tue, 13 Oct 2009 03:18:14 -0700 (PDT)
Message-ID: <20091013.031814.100807531.davem@davemloft.net>
References: <4AC78F7C.40908@gmail.com>
	<4ACCB6BE.5040602@gmail.com>
	<4ACF4C1C.4050505@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org,
	Ralf.Hildebrandt-jq1tPX9l7E6ELgA04lAiVw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	yjwei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, tyasui-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, haoki-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4ACF4C1C.4050505-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Fri, 09 Oct 2009 16:43:40 +0200

> [PATCH] udp: Fix udp_poll()
> 
> udp_poll() can in some circumstances drop frames with incorrect checksums.
> 
> Problem is we now have to lock the socket while dropping frames, or risk
> sk_forward corruption.
> 
> This bug is present since commit 95766fff6b9a78d1
> ([UDP]: Add memory accounting.)
> 
> While we are at it, we can correct ioctl(SIOCINQ) to also drop bad frames.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Looks good, applied, thanks Eric!
