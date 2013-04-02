From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] of_net.h: Provide dummy functions if OF_NET is not
 configured
Date: Tue, 02 Apr 2013 14:33:19 -0400 (EDT)
Message-ID: <20130402.143319.1782388191427921383.davem@davemloft.net>
References: <5159D588.5070603@gmail.com>
	<20130401190100.GA1042@roeck-us.net>
	<5159DC82.3050804@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@roeck-us.net, linux-kernel@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, netdev@vger.kernel.org,
	rob.herring@calxeda.com, david.daney@cavium.com
To: robherring2@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5159DC82.3050804@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rob Herring <robherring2@gmail.com>
Date: Mon, 01 Apr 2013 14:14:10 -0500

> On 04/01/2013 02:01 PM, Guenter Roeck wrote:
>> On Mon, Apr 01, 2013 at 01:44:24PM -0500, Rob Herring wrote:
>>> On 04/01/2013 01:19 PM, Guenter Roeck wrote:
>>>> of_get_mac_address() and of_get_phy_mode() are only provided if OF_NET
>>>> is configured. While most callers check for the define, not all do, and those
>>>> who do require #ifdef around the code. For those who don't, the missing check
>>>> can result in errors such as
>>>
>>> How about removing the ifdef from those callers?
>>>
>> That would be the next step, after/if this one is accepted.
>> If not, it doesn't make sense to waste my time.
> 
> Assuming that is done:
> 
> Acked-by: Rob Herring <rob.herring@calxeda.com>
> 
> Presumably with the follow-on patches, this can go in thru the net tree.

Indeed, please resubmit this with the follow-on cleanups.

Thanks.
