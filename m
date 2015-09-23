From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] kernel: Remove unneeded return from void functions
Date: Wed, 23 Sep 2015 11:48:10 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1509231147270.4371@nanos>
References: <CAAOQCfQE-eAGYPeKfVnOg8txOVjoTmaK1BANXoarB+cyaFw0gw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, tj@kernel.org, cl@linux-foundation.org,
	john.stultz@linaro.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Guillaume Gomez <guillaume1.gomez@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAOQCfQE-eAGYPeKfVnOg8txOVjoTmaK1BANXoarB+cyaFw0gw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 23 Sep 2015, Guillaume Gomez wrote:

> Signed-off-by: Guillaume Gomez <guillaume1.gomez@gmail.com>
> ---
>  include/linux/clockchips.h      | 2 +-
>  include/linux/crypto.h          | 2 +-
>  include/linux/device.h          | 2 +-
>  include/linux/netdevice.h       | 2 +-
>  include/linux/percpu-refcount.h | 2 +-
>  include/linux/timekeeping.h     | 2 +-
>  kernel/time/clocksource.c       | 4 ++--


Please split that into per subsystem patches so they can independently
applied.

Thanks,

	tglx
