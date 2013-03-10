From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] net: can: af_can.c: Fix checkpatch warnings
Date: Sun, 10 Mar 2013 14:11:48 +0100
Message-ID: <513C8694.9090003@hartkopp.net>
References: <1362918526-26730-1-git-send-email-valentin.ilie@gmail.com> <513C8062.6030001@hartkopp.net> <CACTFLAM4DtRGvEFQo5yXhR4Sjx8hKBJoNqARqA5U+9iQK=gkBg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Valentin Ilie <valentin.ilie@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Daniel Mack <zonque@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACTFLAM4DtRGvEFQo5yXhR4Sjx8hKBJoNqARqA5U+9iQK=gkBg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10.03.2013 14:05, Daniel Mack wrote:


>>> @@ -817,8 +817,7 @@ static int can_notifier(struct notifier_block *nb, unsigned long msg,
>>>               /* create new dev_rcv_lists for this device */
>>>               d = kzalloc(sizeof(*d), GFP_KERNEL);
>>>               if (!d) {
>>> -                     printk(KERN_ERR
>>> -                            "can: allocation of receive list failed\n");
>>> +                     pr_err("can: allocation of receive list failed\n");
>>>                       return NOTIFY_DONE;
>>>               }
>>
>>
>> As i've seen in former patches from Joe Perches OOM messages are obsolete.
>>
>> You could write
>>
>> if(!d)
>>         return NOTIFY_DONE;
>>
>> here instead.
> 
> While at it, why not switch to dev_err() instead?


Hm, no.

1. pr_err() would be fine, as dev_err() is for drivers - and we're in
linux/net here and not in linux/drivers

2. When removing the entire printk() statement there's nothing to be modified left

Regards,
Oliver
