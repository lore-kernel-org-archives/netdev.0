From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 8/9] net: ethernet: ti: cpts: fix overflow check period
Date: Wed, 14 Sep 2016 23:23:43 +0300
Message-ID: <33f6f81b-ce41-4eba-c62d-93cdb06daa8f@ti.com>
References: <20160914130231.3035-1-grygorii.strashko@ti.com>
 <20160914130231.3035-9-grygorii.strashko@ti.com>
 <20160914142503.GF28592@localhost.localdomain>
 <d4cde14a-8147-6097-f034-c9cde6cdb718@ti.com> <20160914200845.GB12195@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, WingMan Kwok <w-kwok2@ti.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([198.47.19.11]:45728 "EHLO bear.ext.ti.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751621AbcINUXs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Sep 2016 16:23:48 -0400
In-Reply-To: <20160914200845.GB12195@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/14/2016 11:08 PM, Richard Cochran wrote:
> On Wed, Sep 14, 2016 at 11:03:18PM +0300, Grygorii Strashko wrote:
>> On 09/14/2016 05:25 PM, Richard Cochran wrote:
>>> On Wed, Sep 14, 2016 at 04:02:30PM +0300, Grygorii Strashko wrote:
>>>> @@ -427,9 +427,6 @@ static void cpts_calc_mult_shift(struct cpts *cpts)
>>>>  	u64 ns;
>>>>  	u64 frac;
>>>>  
>>>> -	if (cpts->cc_mult || cpts->cc.shift)
>>>> -		return;
>>>> -
>>>>  	freq = clk_get_rate(cpts->refclk);
>>>>  
>>>>  	/* Calc the maximum number of seconds which we can run before
>>>
>>> This hunk has nothing to do with $subject.
>>
>> Sry, but I did not get your comment here :(
>> I'd happy to update patch according to your request, but could you provide more info here, pls?
> 
> You added that code in patch #7.  Then you moved it in patch #8.  You
> could have made the code correct in patch #7 to begin with.
> 

Do you mean 
 -	if (cpts->cc_mult || cpts->cc.shift)
 -		return;
??

if yes then those changes are correct as from patch#7 point of 
view, as from patch#8 because they are separate standalone changes.
In patch patch#7 it reasonable to ball out earlier, while in patch#8
it required to move forward a bit as I need to know maxsec. 

Sry, that I'm bothering you with stupid questions.


-- 
regards,
-grygorii
