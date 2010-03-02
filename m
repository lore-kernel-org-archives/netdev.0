From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: Notifier chains bug ?
Date: Tue, 2 Mar 2010 23:42:56 +0800
Message-ID: <20100302153651.GC4014@hack>
References: <4B8C56F0.5090700@gmail.com> <2375c9f91003011924k43f03649y5b4df405d6247a79@mail.gmail.com> <5e9821061003012150y15e543cdkf6f23c3a7a47e4a3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Oleg Kutkov <elenbert@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5e9821061003012150y15e543cdkf6f23c3a7a47e4a3@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 02, 2010 at 07:50:01AM +0200, Oleg Kutkov wrote:
>2010/3/2 Am=C3=A9rico Wang <xiyou.wangcong@gmail.com>:
>> On Tue, Mar 2, 2010 at 8:08 AM, Oleg Kutkov <elenbert@gmail.com> wro=
te:
>>> Hello.
>>> I try to used notifier chains for monitoring network devices events=
=2E
>>> All works perfectly when just i'm connecting/disconnecting network =
cable or
>>> up/down interface via ifconfig.
>>> But when i try to change interface address - nothing happens. Notif=
ier is
>>> don't send any events :(
>>
>> I think you mean IP address? No, NETDEV_CHANGEADDR is for hardware
>> address, not for IP address.
>>
>> If you were changing mac address, you will receive NETDEV_CHANGEADDR=
=2E
>>
>
>Thank for quick answer.
>Yes, i mean IP address. And what about NETDEV_CHANGE ?

It is for rtnetlink state transition.

>Is there possible for monitoring IP address/netmask changing ?
>

AFAIK, no.

Cc'ing netdev experts...
