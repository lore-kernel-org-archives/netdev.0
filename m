From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [v3] prism54: isl_38xx: Replace 'struct timeval'
Date: Tue, 26 Apr 2016 09:10:14 +0000 (UTC)
Message-ID: <20160426091014.6ADE46120F@smtp.codeaurora.org>
References: <20160413060916.GA21184@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, y2038@lists.linaro.org,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Tina Ruchandani <ruchandani.tina@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160413060916.GA21184@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> 'struct timeval' uses a 32-bit seconds field which will overflow in
> year 2038 and beyond. This patch is part of a larger effort to remove
> all instances of 'struct timeval' from the kernel and replace them
> with 64-bit timekeeping variables.
> The patch also fixes the debug printf specifier to avoid the
> seconds value being truncated.
> The patch was build-tested / debugged by removing the
> "if VERBOSE > SHOW_ERROR_MESSAGES" guards.
> 
> Signed-off-by: Tina Ruchandani <ruchandani.tina@gmail.com>
> Suggested-by: Arnd Bergmann <arnd@arndb.de>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
