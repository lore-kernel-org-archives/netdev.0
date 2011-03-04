From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resent] tcp: ioctl type SIOCOUTQNSD returns amount of
 data not sent
Date: Fri, 04 Mar 2011 01:04:28 -0800 (PST)
Message-ID: <20110304.010428.71127798.davem@davemloft.net>
References: <1299228497-21246-1-git-send-email-sledz@dresearch.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, m.schuknecht@dresearch.de
To: sledz@dresearch.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1299228497-21246-1-git-send-email-sledz@dresearch.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steffen Sledz <sledz@dresearch.de>
Date: Fri,  4 Mar 2011 09:48:17 +0100

> diff --git a/include/asm-generic/ioctls.h b/include/asm-generic/ioctls.h
> index 199975f..ef2be0b 100644
> --- a/include/asm-generic/ioctls.h
> +++ b/include/asm-generic/ioctls.h
> @@ -74,6 +74,7 @@
>  #define TCSETXW		0x5435
>  #define TIOCSIG		_IOW('T', 0x36, int)  /* pty: generate signal */
>  #define TIOCVHANGUP	0x5437
> +#define TIOCOUTQNSD	0x5438
>  
>  #define FIONCLEX	0x5450
>  #define FIOCLEX		0x5451

Hitting only asm-generic/ioctls.h is insufficient, many architectures do
not make use of this file and the build will fail for them with your patch
applied.
