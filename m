From: Ed W <lists@wildgooses.com>
Subject: Re: Raise initial congestion window size / speedup slow start?
Date: Wed, 14 Jul 2010 23:05:31 +0100
Message-ID: <4C3E34AB.2060405@wildgooses.com>
References: <4C3D94E3.9080103@wildgooses.com> <4C3DD5EB.9070908@tmr.com> <20100714.111553.104052157.davem@davemloft.net> <4C3E0684.5060409@wildgooses.com> <4C3E1B54.40604@hp.com> <20100714203919.GD6682@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, davidsen@tmr.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100714203919.GD6682@nuttenaction>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14/07/2010 21:39, Hagen Paul Pfeifer wrote:
> * Rick Jones | 2010-07-14 13:17:24 [-0700]:
>
>    
>> There is an effort under way, lead by some folks at Google and
>> including some others, to get the RFC's enhanced in support of the
>> concept of larger initial congestion windows.  Some of the discussion
>> may be in the "tcpm" mailing list (assuming I've not gotten my
>> mailing lists confused).  There may be some previous discussion of
>> that work in the netdev archives as well.
>>      
> tcpm is the right mailing list but there is currently no effort to develop
> this topic. Why? Because is not a standardization issue, rather it is a
> technical issue. You cannot rise the initial CWND and expect a fair behavior.
> This was discussed several times and is documented in several documents and
> RFCs.
>    

I'm sure you have covered this to the point you are fed up, but my 
searches turn up only a smattering of posts covering this - could you 
summarise why "you cannot raise the initial cwnd and expect a fair 
behaviour"?

Initial cwnd was changed (increased) in the past (rfc3390) and the RFC 
claims that studies then suggested that the benefits were all positive. 
Some reasonably smart people have suggested that it might be time to 
review the status quo again so it doesn't seem completely obvious that 
the current number is optimal?

> RFC 5681 Section 3.1. Google employees should start with Section 3. This topic
> pop's of every two months in netdev and until now I _never_ read a
> consolidated contribution.
>    

Sorry, what do you mean by a "consolidated contribution"?

That RFC is a subtle read - it appears to give more specific guidance on 
what to do in certain situations, but I'm not sure I see that it 
improves slow start convergence speed for my situation (large RTT)?  
Would you mind highlighting the new bits for those of us a bit newer to 
the subject?

> Partial local issues can already be "fixed" via route specific ip options -
> see initcwnd.
>    

Oh, excellent.  This seems like exactly what I'm after.  (Thanks Stephen 
Hemminger!)

Many thanks

Ed W
