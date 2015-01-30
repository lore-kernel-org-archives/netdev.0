From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH V2 5/6] rtlwifi: btcoexist: Add routines for RTL8812AE kernel socket communications
Date: Fri, 30 Jan 2015 10:05:24 -0800
Message-ID: <B814EF26-CBC9-43E4-A6C9-761A013F85C1@holtmann.org>
References: <1422304934-9239-1-git-send-email-Larry.Finger@lwfinger.net> <1422304934-9239-6-git-send-email-Larry.Finger@lwfinger.net> <87h9v8zkuh.fsf@kamboji.qca.qualcomm.com> <EC423C22-AEA0-4232-A452-7A131C41780A@holtmann.org> <54CBA0CE.8030800@lwfinger.net>
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8BIT
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Troy Tan <troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54CBA0CE.8030800-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Larry,

>>> I'm adding bluetooth list to the discussion. Full patch is available
>>> here:
>>> 
>>> https://patchwork.kernel.org/patch/5712591/

<snip>

>>> So the wireless driver communicates with the bluetooth driver (which is
>>> not in upstream) via a localhost UDP connection?
>> 
>> I think the first order of business should be to get the Bluetooth driver upstream. Until that has happened this is all kinda pointless discussion.
> 
> I agree with this; however, the last time I tried to submit a BT driver for Realtek, I was told that this driver should use some (as yet included) feature. I have watched the driver development, and if that feature was ever included, it was in a form that I did not recognize. I'm sorry that this is vague, but this happened a long time ago.

if the Bluetooth side is running over USB, then it should be driven from the existing btusb.ko module with a vendor specific ->setup() callback. However nothing materialized that I could merge it.

>>> I know there's a general need for something similar like this, but it
>>> needs to properly discussed and designed.
>> 
>> This is just insane. Clear NAK.
>> 
>> Two kernel modules will not use UDP ports over the loopback interface to communicate with each other.
> 
> I will work on combining the latest BT drivers from Realtek with btusb to see if I can achieve a patch that will both work with the Realtek hardware, and get approval from the reviewers.
> 
> What would be an approved method of communicating between two kernel modules? Is there some example in the kernel that I could study?

We need a btcoex subsystem that both WiFi and Bluetooth can register to and communicate with.

Regards

Marcel
