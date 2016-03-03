From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 6/8] x86: tsc: Always Running Timer (ART) correlated
 clocksource
Date: Thu, 3 Mar 2016 11:21:11 +0100 (CET)
Message-ID: <alpine.DEB.2.11.1603031118430.3597@nanos>
References: <1456978919-30076-1-git-send-email-john.stultz@linaro.org> <1456978919-30076-7-git-send-email-john.stultz@linaro.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: lkml <linux-kernel@vger.kernel.org>,
	"Christopher S. Hall" <christopher.s.hall@intel.com>,
	Prarit Bhargava <prarit@redhat.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Ingo Molnar <mingo@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	kevin.b.stanton@intel.com, kevin.j.clarke@intel.com, hpa@zytor.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: John Stultz <john.stultz@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:57087 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754173AbcCCKWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 05:22:45 -0500
In-Reply-To: <1456978919-30076-7-git-send-email-john.stultz@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Mar 2016, John Stultz wrote:

Subject: x86: tsc: Always Running ...

Please make that:

Subject: x86/tsc: Always Running ...

>  
> +#else
> +
> +#define detect_art()

Inline stub if at all. Why sits detect_art() under CONFIG_CPU_FREQ while the
rest of the art code is not????

Thanks

	tglx
