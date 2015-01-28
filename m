From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] lib/checksum.c: fix carry in csum_tcpudp_nofold
Date: Wed, 28 Jan 2015 05:04:18 -0800
Message-ID: <1422450258.29618.43.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1422439091-31413-1-git-send-email-karl.beldan@rivierawaves.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Karl Beldan <karl.beldan@rivierawaves.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Mike Frysinger <vapier@gentoo.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: Karl Beldan <karl.beldan@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422439091-31413-1-git-send-email-karl.beldan@rivierawaves.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-01-28 at 10:58 +0100, Karl Beldan wrote:
> The carry from the 64->32bits folding was dropped, e.g with:
> saddr=0xFFFFFFFF daddr=0xFF0000FF len=0xFFFF proto=0 sum=1,
> csum_tcpudp_nofold returned 0 instead of 1.
> 
> Signed-off-by: Karl Beldan <karl.beldan@rivierawaves.com>
> Cc: Al Viro <viro@ZenIV.linux.org.uk>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Mike Frysinger <vapier@gentoo.org>
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: stable@vger.kernel.org
> ---
>  lib/checksum.c | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)

Signed-off-by: Eric Dumazet <edumazet@google.com>

Thanks !
