From: Karl Beldan <karl.beldan@gmail.com>
Subject: Re: [PATCH 3.4 140/176] lib/checksum.c: fix carry in
 csum_tcpudp_nofold
Date: Thu, 9 Apr 2015 19:44:08 +0200
Message-ID: <20150409174407.GA8601@magnum.frso.rivierawaves.com>
References: <1428569028-23762-1-git-send-email-lizf@kernel.org>
 <1428569224-23820-140-git-send-email-lizf@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: stable@vger.kernel.org, linux-kernel@vger.kernel.org,
	Karl Beldan <karl.beldan@rivierawaves.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Mike Frysinger <vapier@gentoo.org>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Zefan Li <lizefan@huawei.com>
To: lizf@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:33916 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932753AbbDIRnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 13:43:53 -0400
Content-Disposition: inline
In-Reply-To: <1428569224-23820-140-git-send-email-lizf@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 09, 2015 at 04:46:28PM +0800, lizf@kernel.org wrote:
> From: karl beldan <karl.beldan@gmail.com>
> 
> 3.4.107-rc1 review patch.  If anyone has any objections, please let me know.
> 
> ------------------
> 
> 
> commit 150ae0e94634714b23919f0c333fee28a5b199d5 upstream.
> 

Hi Zefan,

The above patch introduced a build error for some archs, please consider
applying 9ce357795ef208faa0d59894d9d119a7434e37f3 
"lib/checksum.c: fix build for generic csum_tcpudp_nofold" as well.
 
Karl
