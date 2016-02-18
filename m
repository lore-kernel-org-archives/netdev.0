From: John Stultz <john.stultz@linaro.org>
Subject: Re: [PATCH v7 0/8] Patchset enabling hardware based cross-timestamps
 for next gen Intel platforms
Date: Thu, 18 Feb 2016 11:26:24 -0800
Message-ID: <CALAqxLXFVSrGD75gw7FbDtJV_cua9oowit8y=nKGS-YG5cYXAw@mail.gmail.com>
References: <1455308729-6280-1-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Richard Cochran <richardcochran@gmail.com>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"x86@kernel.org" <x86@kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	"Stanton, Kevin B" <kevin.b.stanton@intel.com>,
	kevin.j.clarke@intel.com
To: "Christopher S. Hall" <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455308729-6280-1-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 12, 2016 at 12:25 PM, Christopher S. Hall
<christopher.s.hall@intel.com> wrote:
> Modern Intel hardware adds an Always Running Timer (ART) that allows the
> network and audio device clocks to precisely cross timestamp the device
> clock with the system clock. This allows a precise correlation of the
> device time and system time.

Thanks for your continued persistence here Christopher!  It is looking
pretty good.

I've queued these up for testing, and if that goes well, and don't hit
anything else in review, I'll likely try to submit all but the last
patch (unless there's an acked-by from the maintainer of that code)
through Thomas for 4.6.

(I've already added the function comment fix from Richard)

thanks
-john
