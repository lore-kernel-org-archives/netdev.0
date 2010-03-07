From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: 2.6.33 dies on modprobe
Date: Sun, 7 Mar 2010 23:41:39 +0800
Message-ID: <20100307154139.GA6227@hack>
References: <fa.S/rvLm1aQlDSqPwVJz5B+5vHjbM@ifi.uio.no> <fa.+Pg2gFpQSg5k/1mCpBdt8xMXeqY@ifi.uio.no> <fa.0/xGeZctWXDyX0DAp6opgP1HP7w@ifi.uio.no> <fa.kPSENj9DWu0Q8xolQMDkRvAwxQ0@ifi.uio.no> <fa.JUJQsT7bECqtd8JSoNY+SBdASCE@ifi.uio.no> <fa.Lya/54V1PJgwjc8uy1Yk4NyYUh4@ifi.uio.no> <20100303230438.GA3363@invalid> <20100304153042.GA4614@hack> <20100304203803.GA3267@invalid>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>,
	linux-kernel@vger.kernel.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@suse.de>
To: M G Berberich <berberic@fmi.uni-passau.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100304203803.GA3267@invalid>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 04, 2010 at 09:38:03PM +0100, M G Berberich wrote:
>Am Donnerstag, den 04. M=C3=A4rz schrieb Am=C3=A9rico Wang:
>> On Thu, Mar 04, 2010 at 12:04:38AM +0100, M G Berberich wrote:
>> >Am Mittwoch, den 03. M=C3=A4rz schrieb Am=C3=A9rico Wang:
>> >> On Wed, Mar 3, 2010 at 5:08 PM, Am=C3=A9rico Wang <xiyou.wangcong=
@gmail.com> wrote:
>> >> > On Wed, Mar 3, 2010 at 4:58 PM, Am=C3=A9rico Wang <xiyou.wangco=
ng@gmail.com> wrote:
>> >> >> Ok, below is my patch, I am not sure it could fix the BUG for =
you,
>> >> >> but it could fix the WARNING. But perhaps they are related.
>> >> >>
>> >> >> Please give it a try.
>> >> >>
>> >> >
>> >> > Oops! Ignore the patch, it should not be correct, I will send a
>> >> > correct version soon.
>> >> > Sorry.
>> >> >
>> >>=20
>> >> Here we go:
>> >
>> >Seems to fix the warning, but not the modprobe-Oops.
>> >
>>=20
>> Thanks much for your testing!
>>=20
>> Could you please try to turn on DEBUG_KOBJECT and boot your kernel
>> with "initcall_debug"? And then show us your dmesg.
>
>If I'm doing this (enabled CONFIG_DEBUG_KERNEL and
>CONFIG_DEBUG_KOBJECT), the kernel dies immediately - no output.
>

Ouch!

CONFIG_DEBUG_KOBJECT will only enable some printk's, so I think
probably it's CONFIG_DEBUG_KERNEL which breaks your booting.

Could you please provide your .config?

Thanks!
