From: TB <lkml@techboom.com>
Subject: Re: divide error: 0000, in bictcp_cong_avoid, kernel 2.6.39
Date: Thu, 01 Sep 2011 16:30:35 -0400
Message-ID: <4E5FEB6B.2040204@techboom.com>
References: <4E11CCC4.2010404@techboom.com>	<20110704103622.6294f9ed@nehalam.ftrdhcpuser.net>	<4E120208.2090500@techboom.com> <20110705101618.744bbab0@nehalam.ftrdhcpuser.net> <4E1369FA.1090008@techboom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s040.panelboxmanager.com ([72.55.186.60]:59793 "EHLO
	s040.panelboxmanager.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757887Ab1IAVE4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 17:04:56 -0400
In-Reply-To: <4E1369FA.1090008@techboom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11-07-05 03:46 PM, TB wrote:
> On 11-07-05 01:16 PM, Stephen Hemminger wrote:
>> On Mon, 04 Jul 2011 14:10:16 -0400
>> TB <lkml@techboom.com> wrote:
>>
>>> On 11-07-04 01:36 PM, Stephen Hemminger wrote:
>>>> Any data about the type of connection, kernel configuration or other
>>>> information that might be useful in reproducing the problem?
>>>>
>>>> Also please try 2.6.39.2
>>>
>>> We haven't found a sure way of reproducing it.
>>> It happened on 1.2% of our servers over the weekend and seems random.
>>> Both are connected with 2 gigabit ports using bonding. Traffic tends to
>>> be heavy, but doesn't seem to be a factor.
>>>
>>> Would a .config help ?
>>>
>>> Only the very basic filter module for iptables is compiled in.
>>>
>>> We will try 2.6.39.2 soon
>>
>> Kernel config (and compiler version) would help in identifying which
>> of the three divides is getting divide by zero.
> 
> # gcc --version
> gcc (Debian 4.3.2-1.1) 4.3.2
> 
> 
> # as --version
> GNU assembler (GNU Binutils for Debian) 2.18.0.20080103
> This assembler was configured for a target of `x86_64-linux-gnu'.

We have tried 3.0.4 and the bug is still present, however we have still
been unable to get a proper backtrace. It seems a lot of times the
netlog isn't working.
