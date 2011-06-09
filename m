From: WeipingPan <panweiping3@gmail.com>
Subject: Re: [PATCH] bonding: use new value of lacp_rate and ad_select
Date: Thu, 09 Jun 2011 15:09:50 +0800
Message-ID: <4DF071BE.1080006@gmail.com>
References: <1307413455-6942-1-git-send-email-panweiping3@gmail.com>	<4DF03894.2090202@gmail.com>	<BANLkTimb-ankqNPyvcJMJY24zf9hB5AgOQ@mail.gmail.com> <BANLkTik4az0FF+AUo1SbmvhJhKP-bBG4Fw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jpirko@redhat.com, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	open list <linux-kernel@vger.kernel.org>
To: =?UTF-8?B?QW3DqXJpY28gV2FuZw==?= <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BANLkTik4az0FF+AUo1SbmvhJhKP-bBG4Fw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/09/2011 11:15 AM, Am=C3=A9rico Wang wrote:
> On Thu, Jun 9, 2011 at 11:13 AM, Am=C3=A9rico Wang<xiyou.wangcong@gma=
il.com>  wrote:
>> On Thu, Jun 9, 2011 at 11:05 AM, WeipingPan<panweiping3@gmail.com>  =
wrote:
>>> On 06/07/2011 10:24 AM, Weiping Pan wrote:
>>>> There is bug that when you modify lacp_rate via sysfs,
>>>> 802.3ad won't use the new value of lacp_rate to transmit packets.
>>>> This is because port->actor_oper_port_state isn't changed.
>>>>
>>>> As for ad_select, it can work,
>>>> but both struct bond_params and ad_bond_info have lacp_fast and ad=
_select,
>>>> they are duplicate and need extra synchronization.
>>>> 802.3ad can get them from bond_params directly every time.
>>>>
>>> Any comments ?
>>>
>> I think you'd better separate bug fix from cleanup's.
>>
> By the way, please mark the version of your patch in $subject,
> in this case, V3. And describe what you changed from V2.
ok, I will split the patch.

thanks
Weiping Pan
