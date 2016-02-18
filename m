From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v7 5/8] time: Add history to cross timestamp interface
 supporting slower devices
Date: Thu, 18 Feb 2016 23:17:04 +0100
Message-ID: <20160218221704.GA26007@localhost.localdomain>
References: <1455308729-6280-1-git-send-email-christopher.s.hall@intel.com>
 <1455308729-6280-6-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tglx@linutronix.de, mingo@redhat.com, john.stultz@linaro.org,
	hpa@zytor.com, jeffrey.t.kirsher@intel.com, x86@kernel.org,
	linux-kernel@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, kevin.b.stanton@intel.com,
	kevin.j.clarke@intel.com
To: "Christopher S. Hall" <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1455308729-6280-6-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 12, 2016 at 12:25:26PM -0800, Christopher S. Hall wrote:
>  /**
>   * get_device_system_crosststamp - Synchronously capture system/device timestamp
> - * @sync_devicetime:	Callback to get simultaneous device time and
> + * @get_time_fn:	Callback to get simultaneous device time and

Fold this into earlier patch?

>   *	system counter from the device driver
> + * @history_ref:	Historical reference point used to interpolate system
> + *	time when counter provided by the driver is before the current interval

KernelDoc says history_ref,

>   * @xtstamp:		Receives simultaneously captured system and device time
>   *
>   * Reads a timestamp from a device and correlates it to system time
> @@ -920,6 +1035,7 @@ int get_device_system_crosststamp(int (*get_time_fn)
>  				   struct system_counterval_t *sys_counterval,
>  				   void *ctx),
>  				  void *ctx,
> +				  struct system_time_snapshot *history_begin,
>  				  struct system_device_crosststamp *xtstamp)

... but parameter is called history_begin.

Thanks,
Richard
