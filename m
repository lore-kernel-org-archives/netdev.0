From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: Remove IRQF_SAMPLE_RANDOM flag from
 network drivers
Date: Wed, 30 Mar 2011 22:28:32 -0700 (PDT)
Message-ID: <20110330.222832.193698433.davem@davemloft.net>
References: <1301365651-9106-1-git-send-email-martinez.javier@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, ffainelli@freebox.fr,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: martinez.javier@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1301365651-9106-1-git-send-email-martinez.javier@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Javier Martinez Canillas <martinez.javier@gmail.com>
Date: Tue, 29 Mar 2011 04:27:31 +0200

> The IRQF_SAMPLE_RANDOM flag is marked as deprecated and will be removed.
> 
> Every input point to the kernel's entropy pool have to better document the
> type of entropy source it is.
> 
> drivers/char/random.c now implements a set of interfaces that can be used for
> devices to collect enviromental noise. IRQF_SAMPLE_RANDOM will be replaced
> with these add_*_randomness exported functions.
> 
> Network drivers are not a good source of entropy. They use as a source of
> entropy essentially a remote host. Which means that the source of entropy can
> be potentially controlled by an attacker. Also, with heavy workloads the
> entropy decreases due to less hardware interrupts happening thanks to irq
> mitigation and NAPI.
> 
> If a system relies in its network interface as a entropy source it has a false
> sense of security. Systems that don't have devices whose drivers are good
> sources of entropy, should either use a hardware random number generator or
> feed the kernel's entropy pool from userspace using other sources of entropy
> such as EGD, video_entropyd, timer_entropyd and audio-entropyd.
> 
> Signed-off-by: Javier Martinez Canillas <martinez.javier@gmail.com>

Appied to net-next-2.6, thanks!
