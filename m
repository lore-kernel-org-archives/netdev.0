From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] TX throttling bug-fixing patch of AX88179_178A
Date: Tue, 23 Jul 2013 17:17:14 -0700 (PDT)
Message-ID: <20130723.171714.1806972255458292929.davem@davemloft.net>
References: <20130723.164656.1794159338719943519.davem@davemloft.net>
	<1374623813.3449.52.camel@edumazet-glaptop>
	<1374624310.3449.53.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, oliver@neukum.org, grundler@google.com,
	freddy@asix.com.tw, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	louis@asix.com.tw, allan@asix.com.tw
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1374624310.3449.53.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 23 Jul 2013 17:05:10 -0700

> On Tue, 2013-07-23 at 16:56 -0700, Eric Dumazet wrote:
> 
>> > A quick scan shows that smsc75xx, smsc95xx, and ax88179_178a all have
>> > this problem.
>> > 
>> > Instead of the patch starting this thread, I'd like to see one that
>> > hits all three drivers and removes all SG and TSO features bits from
>> > both the ->features _and_ ->hw_features settings.
>> > 
>> > Could someone toss that together quickly?
>> 
>> Yes, I can prepare this patch.
> 
> Looks like only ax88179_178a & smsc75xx are impacted.

Indeed, smsc95xx doesn't set SG or TSO.

Sorry about that.
