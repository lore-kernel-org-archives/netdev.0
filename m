From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3.4 140/176] lib/checksum.c: fix carry in
 csum_tcpudp_nofold
Date: Thu, 09 Apr 2015 14:20:23 -0400 (EDT)
Message-ID: <20150409.142023.414084484839805822.davem@davemloft.net>
References: <1428569028-23762-1-git-send-email-lizf@kernel.org>
	<1428569224-23820-140-git-send-email-lizf@kernel.org>
	<20150409174407.GA8601@magnum.frso.rivierawaves.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lizf@kernel.org, stable@vger.kernel.org,
	linux-kernel@vger.kernel.org, karl.beldan@rivierawaves.com,
	viro@ZenIV.linux.org.uk, eric.dumazet@gmail.com, arnd@arndb.de,
	vapier@gentoo.org, netdev@vger.kernel.org, edumazet@google.com,
	lizefan@huawei.com
To: karl.beldan@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150409174407.GA8601@magnum.frso.rivierawaves.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Karl Beldan <karl.beldan@gmail.com>
Date: Thu, 9 Apr 2015 19:44:08 +0200

> On Thu, Apr 09, 2015 at 04:46:28PM +0800, lizf@kernel.org wrote:
>> From: karl beldan <karl.beldan@gmail.com>
>> 
>> 3.4.107-rc1 review patch.  If anyone has any objections, please let me know.
>> 
>> ------------------
>> 
>> 
>> commit 150ae0e94634714b23919f0c333fee28a5b199d5 upstream.
>> 
> 
> Hi Zefan,
> 
> The above patch introduced a build error for some archs, please consider
> applying 9ce357795ef208faa0d59894d9d119a7434e37f3 
> "lib/checksum.c: fix build for generic csum_tcpudp_nofold" as well.

+1
