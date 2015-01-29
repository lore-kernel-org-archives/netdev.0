From: Karl Beldan <karl.beldan@gmail.com>
Subject: Re: [PATCH v2] lib/checksum.c: fix carry in csum_tcpudp_nofold
Date: Thu, 29 Jan 2015 09:55:52 +0100
Message-ID: <20150129085538.GA32535@magnum.frso.rivierawaves.com>
References: <1422439091-31413-1-git-send-email-karl.beldan@rivierawaves.com>
 <20150128.223249.779296549693168395.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: karl.beldan@rivierawaves.com, viro@ZenIV.linux.org.uk,
	eric.dumazet@gmail.com, arnd@arndb.de, vapier@gentoo.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150128.223249.779296549693168395.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 28, 2015 at 10:32:49PM -0800, David Miller wrote:
> From: Karl Beldan <karl.beldan@gmail.com>
> Date: Wed, 28 Jan 2015 10:58:11 +0100
> 
> > The carry from the 64->32bits folding was dropped, e.g with:
> > saddr=0xFFFFFFFF daddr=0xFF0000FF len=0xFFFF proto=0 sum=1,
> > csum_tcpudp_nofold returned 0 instead of 1.
> > 
> > Signed-off-by: Karl Beldan <karl.beldan@rivierawaves.com>
> 
> Applied, thanks.

Fengguang's robot reported I managed to break the build, this occurs
when using non-generic do_csum and generic csum_tcpudp_nofold.
I guess a v3 is irrelevant now, should I send another patch for the
build fix only ? Sorry for that.
 
Karl
