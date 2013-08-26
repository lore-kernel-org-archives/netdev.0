From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND V3 net-next 2/3] net: huawei_cdc_ncm: Introduce
 the huawei_cdc_ncm driver
Date: Mon, 26 Aug 2013 17:09:22 -0400 (EDT)
Message-ID: <20130826.170922.2228024390320689580.davem@davemloft.net>
References: <1377549913.1877.12.camel@joe-AO722>
	<20130826.165831.112649899191508957.davem@davemloft.net>
	<1377551155.1877.18.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mrkiko.rs@gmail.com, gregkh@linuxfoundation.org, oliver@neukum.org,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377551155.1877.18.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 26 Aug 2013 14:05:55 -0700

> On Mon, 2013-08-26 at 16:58 -0400, David Miller wrote:
>> From: Joe Perches <joe@perches.com>
>> Date: Mon, 26 Aug 2013 13:45:13 -0700
>> 
>> > I think the premise of local variable
>> > declaration by line length is flawed.
>> 
>> I disagree.
>> 
>> > It can't work when local variables are
>> > dependent on initialization order as
>> > above.
>> 
>> Move the initialization below the declarations.
> 
> So all initializations should be on separate
> lines from declarations?

No, you can often make it work out when the initialization
occurs on the same time.

Like everything else in life, you evaluate it on a case by
case basis.

Don't try to over-simplify things and act as if they are black
and white when they aren't.
