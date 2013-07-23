From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] TX throttling bug-fixing patch of AX88179_178A
Date: Tue, 23 Jul 2013 16:46:56 -0700 (PDT)
Message-ID: <20130723.164656.1794159338719943519.davem@davemloft.net>
References: <1374518841.4990.26.camel@edumazet-glaptop>
	<1374522471.1635.48.camel@bwh-desktop.uk.level5networks.com>
	<1374559827.4990.143.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, oliver@neukum.org, grundler@google.com,
	freddy@asix.com.tw, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	louis@asix.com.tw, allan@asix.com.tw
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1374559827.4990.143.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 22 Jul 2013 23:10:27 -0700

> On Mon, 2013-07-22 at 20:47 +0100, Ben Hutchings wrote:
>> The real solution would be for someone to add SG support to the usbnet
>> core.  Trying to support 1GbE with only linear skbs is not a great
>> idea... and it can only be a matter of time before there is USB ultra
>> speed (or whatever comes after 'super') with 10GbE devices...
>> 
> 
> This sounds a good idea.
> 
> Is anybody working on adding SG to usbnet ?

This is a good long-term plan, but right now we have to do something
reasonable.

A quick scan shows that smsc75xx, smsc95xx, and ax88179_178a all have
this problem.

Instead of the patch starting this thread, I'd like to see one that
hits all three drivers and removes all SG and TSO features bits from
both the ->features _and_ ->hw_features settings.

Could someone toss that together quickly?

Thanks.
