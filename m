From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v8 3/8] time: Remove duplicated code in
 ktime_get_raw_and_real()
Date: Wed, 24 Feb 2016 11:52:08 +0100 (CET)
Message-ID: <alpine.DEB.2.11.1602241151180.3670@nanos>
References: <1456139726-3327-1-git-send-email-christopher.s.hall@intel.com> <1456139726-3327-4-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: richardcochran@gmail.com, mingo@redhat.com, john.stultz@linaro.org,
	hpa@zytor.com, jeffrey.t.kirsher@intel.com, x86@kernel.org,
	linux-kernel@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, kevin.b.stanton@intel.com,
	kevin.j.clarke@intel.com
To: "Christopher S. Hall" <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456139726-3327-4-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 22 Feb 2016, Christopher S. Hall wrote:

> --- a/kernel/time/timekeeping.c
> +++ b/kernel/time/timekeeping.c
> @@ -888,6 +888,8 @@ void ktime_get_snapshot(struct system_time_snapshot *systime_snapshot)
>  	s64 nsec_real;
>  	cycle_t now;
>  
> +	WARN_ON(timekeeping_suspended);

WARN_ON_ONCE please

Other than that: Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
