From: "Maksim (Max) Krasnyanskiy" <maxk@qualcomm.com>
Subject: Re: rtnetlink interface state monitoring problems.
Date: Wed, 23 Oct 2002 12:41:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5.1.0.14.2.20021023123707.09b5b168@mail1.qualcomm.com>
References: <24818.1035226670@passion.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>, David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <Pine.GSO.4.30.0210222055170.24323-100000@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jamal,

>> But Bluetooth devices are not network devices, it seems. There exists no
>> current mechanism for notifying anyone of state changes. Should we invent a
>> new method of notification using netlink, or should Bluetooth interfaces in
>> fact be normal network devices just like IrDA devices are?
>>
>
>I think the only time you should go netdev is when it makes sense to run IP. 
Totally agree.

>Is there IP over bluttooth? 
Yep. It's called BNEP (Bluetooth Network Encapsulation Protocol) which is bascially
an Ethernet emulation. That thing is the netdev of course.

>Then you could take advantage of all the nice features provided by netdevices (other 
>than being IP devices;->).
>If not, it probably time for someone to write a generic notification
>scheme via netlink.
Might be interesting.

Max
