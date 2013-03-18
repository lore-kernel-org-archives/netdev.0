From: Silviu Popescu <silviupopescu1990@gmail.com>
Subject: Re: [PATCH] bluetooth: use PTR_RET instead of IS_ERR + PTR_ERR
Date: Mon, 18 Mar 2013 20:13:50 +0200
Message-ID: <CAPWTe+Kfr=zD6oJsfX3W8Ze1iH+CoEHx5FXo4YaVtQuMHD5k_g@mail.gmail.com>
References: <1363111995-26866-1-git-send-email-silviupopescu1990@gmail.com>
	<20130313.053145.2200448840921851390.davem@davemloft.net>
	<CAPWTe+JzznuWYKksAfxkD=u9kv8DuAF4v2AWVxd2OUeDtCYKBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-bluetooth@vger.kernel.org, marcel@holtmann.org,
	gustavo@padovan.org, johan.hedberg@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPWTe+JzznuWYKksAfxkD=u9kv8DuAF4v2AWVxd2OUeDtCYKBA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 18, 2013 at 8:05 PM, Silviu Popescu
<silviupopescu1990@gmail.com> wrote:
> On Wed, Mar 13, 2013 at 11:31 AM, David Miller <davem@davemloft.net> wrote:
>> From: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
>> Date: Tue, 12 Mar 2013 20:13:15 +0200
>>
>>> @@ -590,10 +590,7 @@ int __init bt_sysfs_init(void)
>>>       bt_debugfs = debugfs_create_dir("bluetooth", NULL);
>>>
>>>       bt_class = class_create(THIS_MODULE, "bluetooth");
>>> -     if (IS_ERR(bt_class))
>>> -             return PTR_ERR(bt_class);
>>> -
>>> -     return 0;
>>> +     return PTR_RET(bt_class)
>>
>> Don't bother submitting patches you aren't even going to try
>> to compile.
>>
>> I'm rejecting all of your current submissions.  Resubmit them
>> when you feel like typing 'make' from time to time.
>>
>>
>
> Sorry for the trouble caused and sorry for the late reply.
> That being said, I'd like to understand a bit better what exactly I messed up.
> I've just pulled the latest revision of the mainline kernel and made
> the changes in this patch.
> I've tried with make defconfig (which would be x86_64_defconfig in my
> case), followed by
> make menuconfig to select the bluetooth options and make allyesconfig.
> Both defconfig and allyesconfig compile successfully on my system.
> Would you be so kind as to tell me what error you have encountered?
> Or perhaps enlighten me as to what I'm still doing wrong. I'd like to
> learn from my mistakes.

Please ignore this gratuitous stupidity.
The right patch was applied locally, the wrong one sent to the list.
I'll resubmit the proper one.

-- 
Silviu Popescu
