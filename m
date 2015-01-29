From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] lib/checksum.c: fix build for generic
 csum_tcpudp_nofold
Date: Thu, 29 Jan 2015 11:58:02 -0800 (PST)
Message-ID: <20150129.115802.183887965745286030.davem@davemloft.net>
References: <1422526222-2445-1-git-send-email-karl.beldan@rivierawaves.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: karl.beldan@rivierawaves.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, edumazet@google.com
To: karl.beldan@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422526222-2445-1-git-send-email-karl.beldan@rivierawaves.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Karl Beldan <karl.beldan@gmail.com>
Date: Thu, 29 Jan 2015 11:10:22 +0100

> Fixed commit added from64to32 under _#ifndef do_csum_ but used it
> under _#ifndef csum_tcpudp_nofold_, breaking some builds (Fengguang's
> robot reported TILEGX's). Move from64to32 under the latter.
> 
> Fixes: 150ae0e94634 ("lib/checksum.c: fix carry in csum_tcpudp_nofold")
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Karl Beldan <karl.beldan@rivierawaves.com>

Applied.
