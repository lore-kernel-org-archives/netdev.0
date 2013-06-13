From: David Miller <davem@davemloft.net>
Subject: Re: NULL pointer dereference when loading the gre module
 (3.10.0-rc4)
Date: Thu, 13 Jun 2013 03:01:29 -0700 (PDT)
Message-ID: <20130613.030129.858604303672324590.davem@davemloft.net>
References: <20130606221656.GA11475@uio.no>
	<20130607030648.GA28618@home.goodmis.org>
	<1370577588.24311.407.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, sgunderson@bigfoot.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rusty@rustcorp.com.au
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1370577588.24311.407.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 06 Jun 2013 20:59:48 -0700

> On Thu, 2013-06-06 at 23:06 -0400, Steven Rostedt wrote:
>> On Fri, Jun 07, 2013 at 12:16:56AM +0200, Steinar H. Gunderson wrote:
>> > Hi,
>> > 
>> > In 3.10.0-rc4, I get this on boot:
>> > 
>> > [   16.871043] BUG: unable to handle kernel NULL pointer dereference at 0000000000000003
>> > [   16.879453] IP: [<ffffffffa0e52002>] 0xffffffffa0e52001
>> 
>> Strange, kallsyms should have registered the address already, even if it
>> crashed on early module load. Not sure why it's not reporting it. Well,
>> it seems to have reported some of the symbols of ip_gre below. Maybe
>> this pointer is just totally screwed up.
> 
> I could not reproduce this here.
> 
> Steinar, please make sure you recompiled your modules, because this
> looks like you loaded old modules.

I applied Eric's fixed version of the patch, thanks.
