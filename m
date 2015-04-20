From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 03/11] time/hrtimer:Introduce hrtimer_get_res64() with
 timespec64 type for getting the timer resolution
Date: Mon, 20 Apr 2015 21:15:55 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1504202114360.13914@nanos>
References: <1429509459-17068-1-git-send-email-baolin.wang@linaro.org> <1429509459-17068-4-git-send-email-baolin.wang@linaro.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: arnd@arndb.de, john.stultz@linaro.org, heenasirwani@gmail.com,
	pang.xunlei@linaro.org, peterz@infradead.org,
	rafael.j.wysocki@intel.com, gregkh@linuxfoundation.org,
	richardcochran@gmail.com, benh@kernel.crashing.org,
	paulus@samba.org, mpe@ellerman.id.au, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, linux390@de.ibm.com, rth@twiddle.net,
	riel@redhat.com, cl@linux.com, tj@kernel.org, fweisbec@gmail.com,
	ahh@google.com, pjt@google.com, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	y2038@lists.linaro.org
To: Baolin Wang <baolin.wang@linaro.org>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1429509459-17068-4-git-send-email-baolin.wang@linaro.org>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 Apr 2015, Baolin Wang wrote:
> This patch introduces hrtimer_get_res64() function to get the timer resolution
> with timespec64 type, and moves the hrtimer_get_res() function into

FYI, That function is about to go away, but it's not a big deal to
sort that out once I applied the hrtimer rework to the tip tree.

Thanks,

	tglx
