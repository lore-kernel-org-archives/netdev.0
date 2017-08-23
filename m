From: David Miller <davem@davemloft.net>
Subject: Re: Stable apply request
Date: Wed, 23 Aug 2017 11:07:23 -0700 (PDT)
Message-ID: <20170823.110723.2236835197336811381.davem@davemloft.net>
References: <1498556084-25346-1-git-send-email-jeffy.chen@rock-chips.com>
        <0815411E-62D7-42DC-A0BF-78FD150C0949@holtmann.org>
        <373da46b-41f7-9aa2-946d-75633c9efe86@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcel@holtmann.org, jeffy.chen@rock-chips.com,
        stable@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-bluetooth@vger.kernel.org, rvaswani@nvidia.com,
        briannorris@chromium.org, dmitry.torokhov@gmail.com,
        dianders@chromium.org, acho@suse.com, johan.hedberg@gmail.com,
        netdev@vger.kernel.org, gustavo@padovan.org
To: jslaby@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <373da46b-41f7-9aa2-946d-75633c9efe86@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Slaby <jslaby@suse.cz>
Date: Wed, 23 Aug 2017 09:29:44 +0200

> On 06/27/2017, 07:32 PM, Marcel Holtmann wrote:
>>> It looks like bnep_session has same pattern as the issue reported in
>>> old rfcomm:
>>>
>>> 	while (1) {
>>> 		set_current_state(TASK_INTERRUPTIBLE);
>>> 		if (condition)
>>> 			break;
>>> 		// may call might_sleep here
>>> 		schedule();
>>> 	}
>>> 	__set_current_state(TASK_RUNNING);
>>>
>>> Which fixed at:
>>> 	dfb2fae Bluetooth: Fix nested sleeps
>>>
>>> So let's fix it at the same way, also follow the suggestion of:
>>> https://lwn.net/Articles/628628/
> 
> ...
> 
>> all 3 patches have been applied to bluetooth-next tree.
> 
> Hi,
> 
> given users are hitting it in at least 4.4 and 4.12, can we have all
> three in all stables where this applies?
> 
> 5da8e47d849d Bluetooth: hidp: fix possible might sleep error in
> hidp_session_thread
> f06d977309d0 Bluetooth: cmtp: fix possible might sleep error in cmtp_session
> 25717382c1dd Bluetooth: bnep: fix possible might sleep error in bnep_session
> 
> I am not sure: to stable directly or via net stable?

I generally let the wireless family handle their own -stable submissions
and that includes bluetooth.
