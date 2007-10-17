From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: [RFD] iptables:  mangle table obsoletes filter table
Date: Wed, 17 Oct 2007 19:24:16 -0400
Message-ID: <471699A0.3060303@tmr.com>
References: <200710120031.42805.a1426z@gawab.com> <470EF994.4080403@trash.net> <200710120837.18152.a1426z@gawab.com> <47168EA1.1080300@tmr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Al Boldi <a1426z@gawab.com>, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-net@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bill Davidsen <davidsen@tmr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tmr.com ([64.65.253.246]:50675 "EHLO gaimboi.tmr.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757493AbXJQXPl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 19:15:41 -0400
In-Reply-To: <47168EA1.1080300@tmr.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bill Davidsen wrote:

>>>> If not, then shouldn't the filter table be obsoleted to avoid 
>>>> confusion?
>>> That would probably confuse people. Just don't use it if you don't
>>> need to.
>>
> That is a most practical suggestion.
> 
>> The problem is that people think they are safe with the filter table, 
>> when in fact they need the prerouting chain to seal things.  Right now 
>> this is only possible in the mangle table.
>>
> I'm not sure what you think is unsafe about using the filter table, and 
> the order of evaluation issues certainly seem to suggest that some 
> actions would take a major rethink at least. Perhaps you could avoid 
> breaking all of the setups which currently work, rather than force 
> everyone to do things differently because you feel that your way is better.
> 
It was my intention to suggest that unintentional breakage of existing 
setups should be avoided, not that removing the filter table was some 
evil plot. ;-)
On rereading my original post I failed to make that clear, please take 
it as intended.

-- 
Bill Davidsen <davidsen@tmr.com>
   "We have more to fear from the bungling of the incompetent than from
the machinations of the wicked."  - from Slashdot
