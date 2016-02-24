From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v8 1/8] time: Add cycles to nanoseconds translation
Date: Wed, 24 Feb 2016 11:49:10 +0100 (CET)
Message-ID: <alpine.DEB.2.11.1602241148590.3670@nanos>
References: <1456139726-3327-1-git-send-email-christopher.s.hall@intel.com> <1456139726-3327-2-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: richardcochran@gmail.com, mingo@redhat.com, john.stultz@linaro.org,
	hpa@zytor.com, jeffrey.t.kirsher@intel.com, x86@kernel.org,
	linux-kernel@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, kevin.b.stanton@intel.com,
	kevin.j.clarke@intel.com
To: "Christopher S. Hall" <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456139726-3327-2-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 22 Feb 2016, Christopher S. Hall wrote:

> The timekeeping code does not currently provide a way to translate
> externally provided clocksource cycles to system time. The cycle count
> is always provided by the result clocksource read() method internal to
> the timekeeping code. The added function timekeeping_cycles_to_ns()
> calculated a nanosecond value from a cycle count that can be added to
> tk_read_base.base value yielding the current system time. This allows
> clocksource cycle values external to the timekeeping code to provide a
> cycle count that can be transformed to system time.

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
