From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net: core: move mac_pton() to lib/net_utils.c
Date: Tue, 4 Jun 2013 19:36:20 +0200
Message-ID: <201306041936.21055.arnd@arndb.de>
References: <1370364386-5034-1-git-send-email-andy.shevchenko@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1370364386-5034-1-git-send-email-andy.shevchenko@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 04 June 2013, Andy Shevchenko wrote:
> 
> Since we have at least one user of this function outside of CONFIG_NET
> scope, we have to provide this function independently. The proposed
> solution is to move it under lib/net_utils.c with corresponding
> configuration variable and select wherever it is needed.
> 
> Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>
> Reported-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Arnd Bergmann <arnd@arndb.de>

Thanks for providing a fix so quickly!
