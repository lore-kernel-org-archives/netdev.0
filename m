From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 00/17] sky2 update for 2.6.22
Date: Wed, 09 May 2007 19:27:17 -0400
Message-ID: <464258D5.5040402@garzik.org>
References: <20070509034949.624934448@linux-foundation.org>	<46414B30.6050603@garzik.org> <20070509074811.23ba0bb9@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Greg KH <greg@kroah.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50109 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759775AbXEIX1T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2007 19:27:19 -0400
In-Reply-To: <20070509074811.23ba0bb9@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Wed, 09 May 2007 00:16:48 -0400
> Jeff Garzik <jeff@garzik.org> wrote:
> 
>> Stephen Hemminger wrote:
>>> Patches are against netdev-2.6 upstream code branch.
>>>
>>> This includes a several bug fixes, and code cleanup to use standard
>>> functions. There are a couple of PCI changes. One bug fix, and moving
>>> common code in PCI base.
>> The standard development process is:
>>
>> 	* new code gets pushed to me during 2.6.X-rc
>> 	* that code is auto-propagated to akpm's -mm tree for
>> 	  additional exposure
>> 	* merge window opens
>> 	* I push upstream
>>
>> That ensures code gets at least /some/ additional review, testing, 
>> "settling" time.
> 
> Sorry for the late merge, but between the closing of OSDL office and
> the fixing of critical bugs the other stuff got pushed into the "next release"
> bin and wasn't really ready until now.
> 
>> This is a late date to be expecting stuff to be pushed straight into 2.6.22.
> 
> Then hold it for 2.6.23.

You sure you don't want to split off the bug fixes, and submit those for 
2.6.22?

An oops fix is certainly 2.6.22 material...


>> Additionally, the rule for creating patches is:  diff against latest 
>> vanilla linux-2.6.git tree, unless dependencies exist in netdev.  After 
>> the merge window opens, #upstream is often empty or even a bit behind 
>> upstream, since Linus pulls that.
> 
> One patch wouldn't have applied unless the recent patch that you
> accepted was included.

OK, I stand corrected on this issue, then.  It sounds like you diff'd 
correctly.

	Jeff



