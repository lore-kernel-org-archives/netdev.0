From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 1/4] net/mlx5_core: Fix internal error detection conditions
Date: Wed, 14 Oct 2015 17:47:03 +0300
Message-ID: <CAJ3xEMi=WvU7T1Pd61fBC1vqEkGJGPZwomH=GJ4VYOOogLbW-g@mail.gmail.com>
References: <1444751049-2511-1-git-send-email-ogerlitz@mellanox.com>
	<1444751049-2511-2-git-send-email-ogerlitz@mellanox.com>
	<20151013.194637.203386807677265903.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eli Cohen <eli@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:33815 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753671AbbJNOrE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 10:47:04 -0400
Received: by iow1 with SMTP id 1so57909035iow.1
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 07:47:03 -0700 (PDT)
In-Reply-To: <20151013.194637.203386807677265903.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 14, 2015 at 5:46 AM, David Miller <davem@davemloft.net> wrote:
> From: Or Gerlitz <ogerlitz@mellanox.com>
> Date: Tue, 13 Oct 2015 18:44:06 +0300
>
>> +     if (in_fatal(dev) && !health->sick) {
>> +             health->sick = 1;
>> +             print_health_info(dev);
>> +             queue_work(health->wq, &health->work);
>>       }
>>  }
>>
>> diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
>> index 41a3287..cd469b9 100644
>> --- a/include/linux/mlx5/driver.h
>> +++ b/include/linux/mlx5/driver.h
>> @@ -393,6 +393,7 @@ struct mlx5_core_health {
>>       struct timer_list               timer;
>>       u32                             prev;
>>       int                             miss_counter;
>> +     int                             sick;
>>       struct workqueue_struct        *wq;
>>       struct work_struct              work;
>>  };

> Please use "bool" and true/false for boolean states.

sure, will fix (just sent that..) in V1
