From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v8 4/8] time: Add driver cross timestamp interface for
 higher precision time synchronization
Date: Wed, 24 Feb 2016 11:54:32 +0100 (CET)
Message-ID: <alpine.DEB.2.11.1602241153260.3670@nanos>
References: <1456139726-3327-1-git-send-email-christopher.s.hall@intel.com> <1456139726-3327-5-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: richardcochran@gmail.com, mingo@redhat.com, john.stultz@linaro.org,
	hpa@zytor.com, jeffrey.t.kirsher@intel.com, x86@kernel.org,
	linux-kernel@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, kevin.b.stanton@intel.com,
	kevin.j.clarke@intel.com
To: "Christopher S. Hall" <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456139726-3327-5-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 22 Feb 2016, Christopher S. Hall wrote:
> +int get_device_system_crosststamp(int (*get_time_fn)
> +				  (ktime_t *device_time,
> +				   struct system_counterval_t *sys_counterval,
> +				   void *ctx),
> +				  void *ctx,
> +				  struct system_device_crosststamp *xtstamp)
> +{
> +	struct timekeeper *tk = &tk_core.timekeeper;
> +	unsigned long seq;
> +	struct system_counterval_t system_counterval;
> +	ktime_t base_raw;
> +	ktime_t base_real;
> +	s64 nsec_raw;
> +	s64 nsec_real;

Single lines for same and desceding length ordered, which makes it simpler to
parse, please.

Other than that: Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
