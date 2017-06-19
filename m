From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/2] tcp: md5: add TCP_MD5SIG_EXT socket option to
 set a key address prefix
Date: Mon, 19 Jun 2017 13:52:23 -0400 (EDT)
Message-ID: <20170619.135223.1664090809298285558.davem@davemloft.net>
References: <20170610021449.16091-1-colona@arista.com>
        <20170616010707.27666-1-colona@arista.com>
        <20170616010707.27666-2-colona@arista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colona@arista.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170616010707.27666-2-colona@arista.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivan Delalande <colona@arista.com>
Date: Thu, 15 Jun 2017 18:07:07 -0700

> Replace first padding in the tcp_md5sig structure with a new flag field
> and address prefix length so it can be specified when configuring a new
> key for TCP MD5 signature. The tcpm_flags field will only be used if the
> socket option is TCP_MD5SIG_EXT to avoid breaking existing programs, and
> tcpm_prefixlen only when the TCP_MD5SIG_FLAG_PREFIX flag is set.
> 
> Signed-off-by: Bob Gilligan <gilligan@arista.com>
> Signed-off-by: Eric Mowat <mowat@arista.com>
> Signed-off-by: Ivan Delalande <colona@arista.com>

Applied but I had to renumber TCP_MD5SIG_EXT to 32 since 31 is already
taken by TCP_ULP in my tree.

It's a shame we had to add a new sockopt number to do this, but I can't
think of a better idea.

Thanks.
