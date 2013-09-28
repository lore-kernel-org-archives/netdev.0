From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH 11/12] netfilter: Remove extern from function
 prototypes
Date: Sat, 28 Sep 2013 21:17:54 +0200 (CEST)
Message-ID: <alpine.LSU.2.11.1309282117370.24233@nerf07.vanv.qr>
References: <445209f8885ccd8234fa787c30d63e63fc7917d7.1379961014.git.joe@perches.com> <de1106130366672acb936422f4da7cbb1aafbda1.1379961014.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org
To: Joe Perches <joe@perches.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <de1106130366672acb936422f4da7cbb1aafbda1.1379961014.git.joe@perches.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 2013-09-23 20:37, Joe Perches wrote:

>There are a mix of function prototypes with and without extern
>in the kernel sources.  Standardize on not using extern for
>function prototypes.
>
>Function prototypes don't need to be written with extern.
>extern is assumed by the compiler.  Its use is as unnecessary as
>using auto to declare automatic/local variables in a block.

Or you could just extern all functions for consistency with variables.
