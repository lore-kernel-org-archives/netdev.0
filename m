From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] r8152: rx descriptor check
Date: Mon, 14 Nov 2016 12:27:44 -0500 (EST)
Message-ID: <20161114.122744.544066951483789132.davem@davemloft.net>
References: <20161113.123954.2134945576362221851.davem@davemloft.net>
        <cd36fce8-2f17-debd-d514-e3cbe7ed3762@pobox.com>
        <0835B3720019904CB8F7AA43166CEEB20104EBCC@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mlord@pobox.com, netdev@vger.kernel.org, nic_swsd@realtek.com,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB20104EBCC@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Mon, 14 Nov 2016 07:23:51 +0000

> Mark Lord [mailto:mlord@pobox.com]
>> Sent: Monday, November 14, 2016 4:34 AM
> [...]
>> Perhaps the driver
>> is somehow accessing the buffer space again after doing usb_submit_urb()?
>> That would certainly produce this kind of behaviour.
> 
> I don't think so. First, the driver only read the received buffer.
> That is, the driver would not change (or write) the data. Second,
> The driver would lose the point address of the received buffer
> after submitting the urb to the USB host controller, until the
> transfer is completed by the USB host controller. That is, the
> driver doesn't how to access the buffer after calling usb_submit_urb().

This is why it's most likely some DMA implementation issue or similar.
