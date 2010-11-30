From: Jesse Gross <jesse@nicira.com>
Subject: Re: 2.6.35 -> 2.6.36 panic when vlan and promisc with tg3
Date: Mon, 29 Nov 2010 19:10:06 -0800
Message-ID: <AANLkTi=HHD9KCn8SHDQbbsNJCWDy+iWH8JmzhVUQAvVm@mail.gmail.com>
References: <20101129201716.1d0257c4@xenia.leun.net>
	<4CF442FA.4070701@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Michael Leun <lkml20101129@newton.leun.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CF442FA.4070701@candelatech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 29, 2010 at 4:19 PM, Ben Greear <greearb@candelatech.com> wrote:
> On 11/29/2010 11:17 AM, Michael Leun wrote:
>>
>> Hi,
>>
>> only kernel message I was able to capture on serial were:
>>
>> UG: unable to handle kernel paging request at 01cc921c
>> IP: [<c034bfce>] vlan_hwaccel_do_receive+0x59/0xd0
>> *pdpt = 0000000036a2a001 *pde = 0000000000000000
>> Oops: 0002 [#1] SMP
>> last sysfs
>>
>> Then machine dead.
>>
>> In 2.6.35.x this did not happen (but vlans broken - cannot see vlan
>> tags with tcpdump),
>
> Try this patch:
>
> http://permalink.gmane.org/gmane.linux.network/176566
>
> It looks like this hasn't made it into stable yet?

It didn't make it into 2.6.36.1.

David, I know that you already acked this patch but it sounds like
Greg would prefer to get it from you directly:
https://lkml.org/lkml/2010/11/19/685
