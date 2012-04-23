From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: linux-next: Tree for Apr 23 (ax.25 sysctl)
Date: Mon, 23 Apr 2012 09:25:46 -0700
Message-ID: <4F95828A.8050403@xenotime.net>
References: <20120423170701.c96e402234b1387dece11dda@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, linux-hams@vger.kernel.org,
	Ralf Baechle <ralf@linux-mips.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20120423170701.c96e402234b1387dece11dda@canb.auug.org.au>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/23/2012 12:07 AM, Stephen Rothwell wrote:

> Hi all,
> 
> Changes since 20120420:



include/net/ax25.h:447:75: error: expected ';' before '}' token


static inline int ax25_register_dev_sysctl(ax25_dev *ax25_dev) { return 0 };
static inline void ax25_unregister_dev_sysctl(ax25_dev *ax25_dev) {};

Is this from Eric B.'s sysctl patches?

First function:  move ';' inside braces.
Second function:  drop the ';'.


-- 
~Randy
