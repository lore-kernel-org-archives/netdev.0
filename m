From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH mac80211-next] rfkill: hide unused goto label
Date: Fri, 16 Dec 2016 10:06:54 +0100
Message-ID: <1481879214.27953.0.camel@sipsolutions.net>
References: <20161216084425.1692828-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        =?ISO-8859-1?Q?Jo=E3o?= Paulo Rechi Vita <jprvita@gmail.com>,
        =?UTF-8?Q?Micha=C5=82_K=C4=99pie=C5=84?= <kernel@kempniu.pl>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161216084425.1692828-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-12-16 at 09:44 +0100, Arnd Bergmann wrote:
> A cleanup introduced a harmless warning in some configurations:
> 
> net/rfkill/core.c: In function 'rfkill_init':
> net/rfkill/core.c:1350:1: warning: label 'error_input' defined but
> not used [-Wunused-label]
> 
> This adds another #ifdef around the label to match that around the
> caller.

Applied, thanks.

johannes
