From: "Christopher Hall" <christopher.s.hall@intel.com>
Subject: Re: [PATCH v4 3/4] Add PTP_SYS_OFFSET_PRECISE for driver
 crosstimestamping
Date: Wed, 14 Oct 2015 19:47:32 -0700
Message-ID: <op.x6i0pip51774gr@chall-mobl2.amr.corp.intel.com>
References: <1444675522-4198-1-git-send-email-christopher.s.hall@intel.com>
 <1444675522-4198-4-git-send-email-christopher.s.hall@intel.com>
 <20151013135925.GB5422@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, hpa@zytor.com, mingo@redhat.com,
	tglx@linutronix.de, john.stultz@linaro.org, peterz@infradead.org,
	x86@kernel.org, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kevin.b.stanton@intel.com
To: "Richard Cochran" <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151013135925.GB5422@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Oct 2015 06:59:26 -0700, Richard Cochran  
<richardcochran@gmail.com> wrote:

> On Mon, Oct 12, 2015 at 11:45:21AM -0700, Christopher S. Hall wrote:
>>
>> +struct ptp_sys_offset_precise {
>> +	unsigned int rsv[4];    /* Reserved for future use. */
>> +	struct ptp_clock_time dev;
>> +	struct ptp_clock_time sys;
>> +};
>> +
>
> Please put the reserved field at the bottom.  Also, since we reading
> the raw monotonic time under the hood, we might as well return it in

Good idea.

Thanks,
Chris
