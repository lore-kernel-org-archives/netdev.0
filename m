From: "Christopher Hall" <christopher.s.hall@intel.com>
Subject: Re: [PATCH v7 0/8] Patchset enabling hardware based cross-timestamps
 for next gen Intel platforms
Date: Mon, 22 Feb 2016 10:33:47 -0800
Message-ID: <op.yc8y6lni1774gr@chall-mobl2.amr.corp.intel.com>
References: <1455308729-6280-1-git-send-email-christopher.s.hall@intel.com>
 <CALAqxLXFVSrGD75gw7FbDtJV_cua9oowit8y=nKGS-YG5cYXAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: "Thomas Gleixner" <tglx@linutronix.de>,
	"Richard Cochran" <richardcochran@gmail.com>,
	"Ingo Molnar" <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	"Jeff Kirsher" <jeffrey.t.kirsher@intel.com>,
	"x86@kernel.org" <x86@kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	"Stanton, Kevin B" <kevin.b.stanton@intel.com>,
	kevin.j.clarke@intel.com
To: "John Stultz" <john.stultz@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALAqxLXFVSrGD75gw7FbDtJV_cua9oowit8y=nKGS-YG5cYXAw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 18 Feb 2016 11:26:24 -0800, John Stultz <john.stultz@linaro.org>  
wrote:
> On Fri, Feb 12, 2016 at 12:25 PM, Christopher S. Hall
> <christopher.s.hall@intel.com> wrote:
>> Modern Intel hardware adds an Always Running Timer (ART) that allows the
>> network and audio device clocks to precisely cross timestamp the device
>> clock with the system clock. This allows a precise correlation of the
>> device time and system time.
>
> Thanks for your continued persistence here Christopher!  It is looking
> pretty good.
>
> I've queued these up for testing, and if that goes well, and don't hit
> anything else in review, I'll likely try to submit all but the last
> patch (unless there's an acked-by from the maintainer of that code)
> through Thomas for 4.6.

Hi John,

I just sent another patchset (v8). I corrected the comment problems  
pointed out by Richard Cochran. I also changed the arch/x86 code to use  
"non-stop" TSC rather than "invariant" TSC. They are *exactly* the same  
thing (i.e. read from the same bit of the CPUID leaf). The former exists  
already and should be used instead.  Patch 6/8 is the only patch that is  
changed apart from comments.

Thanks for your help reviewing this.

Chris
