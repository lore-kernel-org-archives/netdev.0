From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v8 6/8] x86: tsc: Always Running Timer (ART) correlated
 clocksource
Date: Wed, 24 Feb 2016 12:00:31 +0100 (CET)
Message-ID: <alpine.DEB.2.11.1602241200020.3670@nanos>
References: <1456139726-3327-1-git-send-email-christopher.s.hall@intel.com> <1456139726-3327-7-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-1502734401-1456311632=:3670"
Cc: richardcochran@gmail.com, mingo@redhat.com, john.stultz@linaro.org,
	hpa@zytor.com, jeffrey.t.kirsher@intel.com, x86@kernel.org,
	linux-kernel@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, kevin.b.stanton@intel.com,
	kevin.j.clarke@intel.com
To: "Christopher S. Hall" <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456139726-3327-7-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1502734401-1456311632=:3670
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Mon, 22 Feb 2016, Christopher S. Hall wrote:

> On modern Intel systems TSC is derived from the new Always Running Timer
> (ART). ART can be captured simultaneous to the capture of
> audio and network device clocks, allowing a correlation between timebases
> to be constructed. Upon capture, the driver converts the captured ART
> value to the appropriate system clock using the correlated clocksource
> mechanism.
> 
> On systems that support ART a new CPUID leaf (0x15) returns parameters
> “m” and “n” such that:
> 
> TSC_value = (ART_value * m) / n + k [n >= 2]
> 
> [k is an offset that can adjusted by a privileged agent. The
> IA32_TSC_ADJUST MSR is an example of an interface to adjust k.
> See 17.14.4 of the Intel SDM for more details]
> 
> Signed-off-by: Christopher S. Hall <christopher.s.hall@intel.com>
> [jstultz: Tweaked to fix build issue, also reworked math for
> 64bit division on 32bit systems]
> Signed-off-by: John Stultz <john.stultz@linaro.org>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
--8323329-1502734401-1456311632=:3670--
