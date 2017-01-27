From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [net] ISDN: eicon: silence misleading array-bounds
 warning
Date: Fri, 27 Jan 2017 11:28:05 -0500 (EST)
Message-ID: <20170127.112805.1527516501880737431.davem@davemloft.net>
References: <20170127123225.3728707-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mac@melware.de, isdn@linux-pingi.de, der.herr@hofr.at,
        kernel-build-reports@lists.linaro.org, stable@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170127123225.3728707-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 27 Jan 2017 13:32:14 +0100

> With some gcc versions, we get a warning about the eicon driver,
> and that currently shows up as the only remaining warning in one
> of the build bots:
> 
> In file included from ../drivers/isdn/hardware/eicon/message.c:30:0:
> eicon/message.c: In function 'mixer_notify_update':
> eicon/platform.h:333:18: warning: array subscript is above array bounds [-Warray-bounds]
> 
> The code is easily changed to open-code the unusual PUT_WORD() line
> causing this to avoid the warning.
> 
> Cc: stable@vger.kernel.org
> Link: http://arm-soc.lixom.net/buildlogs/stable-rc/v4.4.45/
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Ok, applied, thanks Arnd.
