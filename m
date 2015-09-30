From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 1/5] ntp/pps: use timespec64 for hardpps()
Date: Wed, 30 Sep 2015 09:20:21 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1509300920020.4500@nanos>
References: <1443471692-2946597-1-git-send-email-arnd@arndb.de> <1443471692-2946597-2-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: y2038@lists.linaro.org, John Stultz <john.stultz@linaro.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Rodolfo Giometti <giometti@enneenne.com>,
	linux-net-drivers@solarflare.com,
	Shradha Shah <sshah@solarflare.com>,
	Richard Cochran <richardcochran@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443471692-2946597-2-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 28 Sep 2015, Arnd Bergmann wrote:

> There is only one user of the hardpps function in the kernel, so
> it makes sense to atomically change it over to using 64-bit
> timestamps for y2038 safety. In the hardpps implementation,
> we also need to change the pps_normtime structure, which is
> similar to struct timespec and also requires a 64-bit
> seconds portion.
> 
> This introduces two temporary variables in pps_kc_event() to
> do the conversion, they will be removed again in the next step,
> which seemed preferable to having a larger patch changing it
> all at the same time.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
