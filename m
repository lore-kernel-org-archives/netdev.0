From: Kay Sievers <kay@vrfy.org>
Subject: Re: [PATCH] vlan: set sysfs device_type to 'vlan'
Date: Tue, 23 Oct 2012 12:34:11 +0200
Message-ID: <CAPXgP10EhtdCT5Bus2+Prfrk0LU3tEeBJq8qq4hK4k=TdiS5qQ@mail.gmail.com>
References: <1350885237-12998-1-git-send-email-cardoe@cardoe.com> <20121023.023647.2164665243829038911.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: cardoe@cardoe.com, kaber@trash.net, netdev@vger.kernel.org,
	systemd-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121023.023647.2164665243829038911.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 23, 2012 at 8:36 AM, David Miller <davem@davemloft.net> wrote:
> From: Doug Goldstein <cardoe@cardoe.com>
> Date: Mon, 22 Oct 2012 00:53:57 -0500
>
>> Sets the sysfs device_type to 'vlan' for udev. This makes it easier for
>> applications that query network information via udev to identify vlans
>> instead of using strrchr().
>>
>> Signed-off-by: Doug Goldstein <cardoe@cardoe.com>
>
> You're extremely misguided.  This change, in fact, makes it ten times
> harder for such applications to query such devices.

That makes not much sense, really. Every new interface would fall into
that category. At least I can't see any mis-guidance here. The other
devtypes for the major netif types are not that much older.

> Because now the application has to decide whether it wants to support
> EVERY EXISTING SYSTEM OUT THERE or not.  Hundreds of millions of Linux
> systems do not provide this attribute.
>
> Applications have to handle the case of not having the 'vlan' device
> type available attribute essentially forever.

Which is an entirely separate issue, and not a technical reason not to
add new interfaces which are already in use for most other types of
netifs.

> So providing it in new kernels provides zero value whatsoever.

It sure does provide a value. The kernel can efficiently filter
uevents in the socket with this available. All other major types of
netdevs support that too, it's just a matter of completeness. For that
reason, it looks useful to me.

> I'm not applying this patch, sorry.

That's just sad. Not that I really care about that functionality, but
your reasoning is absolutely not transparent.

Kay
