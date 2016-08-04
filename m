From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [RFC 2/4] bpf, security: Add Checmate
Date: Thu, 4 Aug 2016 17:34:32 +0800
Message-ID: <CAD=hENeWDNTQ8oQurdX6kHxuuRVh-DtEDEDH0=-BCM9mqzZn6g@mail.gmail.com>
References: <20160804071140.GA19121@ircssh.c.rugged-nimbus-611.internal>
 <CAD=hENfPUmP6odm+oFg0gAEJ5oqKksTyZPYE1F1iXJW=DS7sqQ@mail.gmail.com> <1470299302.13693.13.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sargun Dhillon <sargun@sargun.me>,
	LKML <linux-kernel@vger.kernel.org>,
	alexei.starovoitov@gmail.com, daniel@iogearbox.net,
	linux-security-module@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1470299302.13693.13.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Sure.
Is it better to add
#ifndef CONFIG_PREEMPT_RCU ?

On Thu, Aug 4, 2016 at 4:28 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Please do not top post
>
> On Thu, 2016-08-04 at 16:08 +0800, zhuyj wrote:
>>  +void register_checmate_prog_ops(void);
>> maybe it is extern void register_checmate_prog_ops(void);?
>>
>> +       preempt_disable();
>> +       rcu_read_lock();
>> IMHO, it is not necessary to use the above 2 since rcu_read_lock will
>> call preempt_disable.
>
> You might double check if this claim is true if CONFIG_PREEMPT_RCU=y
>
>
>
