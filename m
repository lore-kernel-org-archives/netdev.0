From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: compute a more reasonable default ip6_rt_max_size
Date: Fri, 25 May 2012 22:47:00 +0200
Message-ID: <1337978820.10135.1.camel@edumazet-glaptop>
References: <1337976934-18065-1-git-send-email-asharma@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Arun Sharma <asharma@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337976934-18065-1-git-send-email-asharma@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-05-25 at 13:15 -0700, Arun Sharma wrote:
> The algorithm is based on ipv4 and alloc_large_system_hash().
> 

Why is it needed at all ?

IPv4 has a route cache with potentially millions of entries, not IPv6.
