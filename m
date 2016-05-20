From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: pegasus: remove unused variables and labels
Date: Fri, 20 May 2016 09:40:31 -0700 (PDT)
Message-ID: <20160520.094031.1022047118545506778.davem@davemloft.net>
References: <1463732595-3149399-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: petkan@nucleusys.com, xypron.glpk@gmx.de,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463732595-3149399-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 20 May 2016 10:22:30 +0200

> The latest dead-code removal was slightly incomplete and
> left a few things behind that we now get compiler warnings
> for:
> 
> drivers/net/usb/pegasus.c: In function 'read_bulk_callback':
> drivers/net/usb/pegasus.c:475:1: error: label 'goon' defined but not used [-Werror=unused-label]
> drivers/net/usb/pegasus.c:446:8: error: unused variable 'pkt_len' [-Werror=unused-variable]
> drivers/net/usb/pegasus.c:445:6: error: unused variable 'buf' [-Werror=unused-variable]
> drivers/net/usb/pegasus.c:443:17: error: unused variable 'count' [-Werror=unused-variable]
> 
> This removes them as well.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: e00be9e4d0ff ("net: pegasus: remove dead coding")

The patch in question was broken and has been reverted.
