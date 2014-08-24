From: Kalle Valo <kvalo@adurom.com>
Subject: Re: [PATCH] drivers: net: wireless: Add include guards
Date: Sun, 24 Aug 2014 15:01:22 +0300
Message-ID: <87ppfq85bh.fsf@purkki.adurom.net>
References: <1408710414-13810-1-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408710414-13810-1-git-send-email-linux@rasmusvillemoes.dk>
	(Rasmus Villemoes's message of "Fri, 22 Aug 2014 14:26:54 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rasmus Villemoes <linux@rasmusvillemoes.dk> writes:

> The files ray_cs.h and rayctl.h both contain two thirds of what
> appears to be an include guard using the macro name RAYLINK_H (both
> lack the #define). Since RAYLINK_H is not defined anywhere, the
> guards using different macro names.
>
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> ---
>  drivers/net/wireless/ray_cs.h | 5 +++--
>  drivers/net/wireless/rayctl.h | 5 +++--

As this a change to ray_cs driver, please use prefix "ray_cs:" and drop
that "drivers: net: wireless:".

-- 
Kalle Valo
