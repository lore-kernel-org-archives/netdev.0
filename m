From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 1/5] Add functions producing system time given a backing
 counter value
Date: Wed, 29 Jul 2015 12:51:04 +0200
Message-ID: <20150729105104.GN19282@twins.programming.kicks-ass.net>
References: <1438044416-15588-1-git-send-email-christopher.s.hall@intel.com>
 <1438044416-15588-2-git-send-email-christopher.s.hall@intel.com>
 <CALAqxLWSakB1zdnYAE=2yQTPLdzkjO3wLA82Q+CJoJccGLWM8Q@mail.gmail.com>
 <CALAqxLVkwJ5cmvSZ9bL-F7YTFprZ+CvZW4MrMN0sEkk5yFqMRQ@mail.gmail.com>
 <alpine.DEB.2.11.1507291014490.3825@nanos>
 <alpine.DEB.2.11.1507291222190.3825@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Stultz <john.stultz@linaro.org>,
	Christopher Hall <christopher.s.hall@intel.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Ingo Molnar <mingo@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	john.ronciak@intel.com, "H. Peter Anvin" <hpa@zytor.com>,
	"x86@kernel.org" <x86@kernel.org>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1507291222190.3825@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 29, 2015 at 12:23:27PM +0200, Thomas Gleixner wrote:
> +/*
> + * CHECKME: Do we need the adjust value? It should be 0, but if we run
> + * in a VM this might be a different story.
> + */
> +static u64 tsc_adjust;

Urgh, VMs have !0 values here?
