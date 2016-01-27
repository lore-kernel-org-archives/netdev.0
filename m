From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH 5/9] net: fddi/defxx: avoid warning about uninitialized
 variable use
Date: Wed, 27 Jan 2016 15:15:26 +0000 (GMT)
Message-ID: <alpine.LFD.2.20.1601271513480.7055@eddie.linux-mips.org>
References: <1453903507-3427225-1-git-send-email-arnd@arndb.de> <1453903507-3427225-6-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453903507-3427225-6-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 27 Jan 2016, Arnd Bergmann wrote:

> This adds code to ensure that the BAR values are initialized
> even in the impossible case when a device gets probed that
> does not belong to any bus. This shuts up the warning.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  drivers/net/fddi/defxx.c | 5 +++++
>  1 file changed, 5 insertions(+)

 NAK, fixed already, commit 62f2aaabcf41 ("defxx: fix build warning").

 Thanks for looking into this problem though, always welcome!

  Maciej
