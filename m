From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] lib/checksum.c: fix carry in csum_tcpudp_nofold
Date: Wed, 28 Jan 2015 22:32:49 -0800 (PST)
Message-ID: <20150128.223249.779296549693168395.davem@davemloft.net>
References: <1422439091-31413-1-git-send-email-karl.beldan@rivierawaves.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: karl.beldan@rivierawaves.com, viro@ZenIV.linux.org.uk,
	eric.dumazet@gmail.com, arnd@arndb.de, vapier@gentoo.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
To: karl.beldan@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422439091-31413-1-git-send-email-karl.beldan@rivierawaves.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Karl Beldan <karl.beldan@gmail.com>
Date: Wed, 28 Jan 2015 10:58:11 +0100

> The carry from the 64->32bits folding was dropped, e.g with:
> saddr=0xFFFFFFFF daddr=0xFF0000FF len=0xFFFF proto=0 sum=1,
> csum_tcpudp_nofold returned 0 instead of 1.
> 
> Signed-off-by: Karl Beldan <karl.beldan@rivierawaves.com>

Applied, thanks.
