From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: wlcore: Fix regression in wlcore_set_partition()
Date: Tue, 16 Feb 2016 17:24:15 +0200
Message-ID: <87bn7gu19c.fsf@kamboji.qca.qualcomm.com>
References: <20160210012216.GA18819@lianli>
	<20160212094526.EC572611CE@smtp.codeaurora.org>
	<CANfgCY02_AkRi2EMNZsneK8UdwLvAWxF_X0ts6WZbaM0=5c63A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Emil Goode <emil.fsw@goode.io>, Shahar Patury <shaharp@ti.com>,
	Guy Mishol <guym@ti.com>,
	Igor Grinberg <grinberg@compulab.co.il>,
	Uri Mashiach <uri.mashiach@compulab.co.il>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ross Green <rgkernel@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANfgCY02_AkRi2EMNZsneK8UdwLvAWxF_X0ts6WZbaM0=5c63A@mail.gmail.com>
	(Ross Green's message of "Mon, 15 Feb 2016 15:01:49 +1100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ross Green <rgkernel@gmail.com> writes:

> On Fri, Feb 12, 2016 at 8:45 PM, Kalle Valo <kvalo@codeaurora.org> wrote:
>>
>>> The commit 3719c17e1816 ("wlcore/wl18xx: fw logger over sdio") introduced a
>>> regression causing the wlcore to time out and go into recovery. Reverting the
>>> changes regarding write of the last partition size brings the module back to
>>> it's functional state.
>>>
>>> Fixes: 3719c17e1816 ("wlcore/wl18xx: fw logger over sdio")
>>> Reported-by: Ross Green <rgkernel@gmail.com>
>>> Signed-off-by: Emil Goode <emil.fsw@goode.io>
>>> [kvalo@codeaurora.org: improved commit log]
>>
>> Thanks, applied to wireless-drivers.git.
>>
>> Kalle Valo
>
> I just tested linux-4.5-rc4 it appears the above fix missed the release for rc4!
> So the behaviour of firmware reset being called after the access of
> the last partition timesout.
>
> Again tested patch with the new release - 4.5-rc4 and found everything
> to work as expected again.
>
> So Hopefully for rc5 - Please!

It takes some time to get patches into Linus' tree. And being in a
conference and then getting sick is not really helping. I'm not sure if
this patch makes to rc5 on time, but I'll try.

-- 
Kalle Valo
