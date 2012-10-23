From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: set sysfs device_type to 'vlan'
Date: Tue, 23 Oct 2012 13:11:39 -0400 (EDT)
Message-ID: <20121023.131139.1916916979369476334.davem@davemloft.net>
References: <1350885237-12998-1-git-send-email-cardoe@cardoe.com>
	<20121023.023647.2164665243829038911.davem@davemloft.net>
	<CAPXgP10EhtdCT5Bus2+Prfrk0LU3tEeBJq8qq4hK4k=TdiS5qQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cardoe@cardoe.com, kaber@trash.net, netdev@vger.kernel.org,
	systemd-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org
To: kay@vrfy.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPXgP10EhtdCT5Bus2+Prfrk0LU3tEeBJq8qq4hK4k=TdiS5qQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kay Sievers <kay@vrfy.org>
Date: Tue, 23 Oct 2012 12:34:11 +0200

> On Tue, Oct 23, 2012 at 8:36 AM, David Miller <davem@davemloft.net> wrote:
>> From: Doug Goldstein <cardoe@cardoe.com>
>> Date: Mon, 22 Oct 2012 00:53:57 -0500
>>
>>> Sets the sysfs device_type to 'vlan' for udev. This makes it easier for
>>> applications that query network information via udev to identify vlans
>>> instead of using strrchr().
>>>
>>> Signed-off-by: Doug Goldstein <cardoe@cardoe.com>
>>
>> You're extremely misguided.  This change, in fact, makes it ten times
>> harder for such applications to query such devices.
> 
> That makes not much sense, really. Every new interface would fall into
> that category. At least I can't see any mis-guidance here. The other
> devtypes for the major netif types are not that much older.

Only interfaces which provide a facility available in another way
fall into this category.

Thanks for the scarecrow, but no.
