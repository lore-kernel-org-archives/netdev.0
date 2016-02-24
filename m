From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v8 2/8] time: Add timekeeping snapshot code capturing
 system time and counter
Date: Wed, 24 Feb 2016 11:51:12 +0100 (CET)
Message-ID: <alpine.DEB.2.11.1602241150120.3670@nanos>
References: <1456139726-3327-1-git-send-email-christopher.s.hall@intel.com> <1456139726-3327-3-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: richardcochran@gmail.com, mingo@redhat.com, john.stultz@linaro.org,
	hpa@zytor.com, jeffrey.t.kirsher@intel.com, x86@kernel.org,
	linux-kernel@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, kevin.b.stanton@intel.com,
	kevin.j.clarke@intel.com
To: "Christopher S. Hall" <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456139726-3327-3-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 22 Feb 2016, Christopher S. Hall wrote:

> In the current timekeeping code there isn't any interface to
> atomically capture the current relationship between the system counter
> and system time. ktime_get_snapshot() returns this triple (counter,
> monotonic raw, realtime) in the system_time_snapshot struct.

> +/**
> + * ktime_get_snapshot - snapshots the realtime/monotonic raw clocks with counter
> + * @systime_snapshot:	pointer to struct receiving the system time snapshot
> + */
> +void ktime_get_snapshot(struct system_time_snapshot *systime_snapshot)
> +{
> +	struct timekeeper *tk = &tk_core.timekeeper;
> +	unsigned long seq;
> +	ktime_t base_raw;
> +	ktime_t base_real;
> +	s64 nsec_raw;
> +	s64 nsec_real;

I'd prefer to have the variables of the same type in a single line. Other than
that:

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
