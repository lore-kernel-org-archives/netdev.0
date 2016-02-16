From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v7 4/8] time: Add driver cross timestamp interface for
 higher precision time synchronization
Date: Tue, 16 Feb 2016 08:56:38 +0100
Message-ID: <20160216075638.GB2461@localhost.localdomain>
References: <1455308729-6280-1-git-send-email-christopher.s.hall@intel.com>
 <1455308729-6280-5-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tglx@linutronix.de, mingo@redhat.com, john.stultz@linaro.org,
	hpa@zytor.com, jeffrey.t.kirsher@intel.com, x86@kernel.org,
	linux-kernel@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, kevin.b.stanton@intel.com,
	kevin.j.clarke@intel.com
To: "Christopher S. Hall" <christopher.s.hall@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:33488 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754270AbcBPH4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 02:56:44 -0500
Content-Disposition: inline
In-Reply-To: <1455308729-6280-5-git-send-email-christopher.s.hall@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 12, 2016 at 12:25:25PM -0800, Christopher S. Hall wrote:
>  /**
> + * get_device_system_crosststamp - Synchronously capture system/device timestamp
> + * @sync_devicetime:	Callback to get simultaneous device time and
> + *	system counter from the device driver
> + * @xtstamp:		Receives simultaneously captured system and device time
      @ctx:             Private context passed to the 'get_time_fn' callback.

> + *
> + * Reads a timestamp from a device and correlates it to system time
> + */

Thanks,
Richard
