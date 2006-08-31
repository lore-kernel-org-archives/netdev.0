From: "Andrew Hall" <andrew.hall@bluereefnetworks.com>
Subject: Re: [RFT] sky2: transmit complete alternative
Date: Thu, 31 Aug 2006 16:18:38 +1000
Message-ID: <05ba01c6ccc5$4dd64730$5001010a@bluereef.local>
References: <050601c6cc8b$1cb4a8c0$5001010a@bluereef.local> <20060830163636.78fa1aed@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.mud.yahoo.com ([68.142.200.252]:33441 "HELO
	smtp104.biz.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S1750788AbWHaGSn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 02:18:43 -0400
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> On Thu, 31 Aug 2006 09:22:05 +1000
> "Andrew Hall" <andrew.hall@bluereefnetworks.com> wrote:
>
>> Has there been any updates on a fix for the sky2 tx timeout issues?
>>
>> I have been tracking this problem for a while and consistently see this
>> issue when the interface is under heavy load. I'm using 2.6.17.11 but 
>> have
>> tried .15, .16, .17 and .18rcX all with the same issue - a large amount 
>> of
>> (HTTP generated test workload) traffic will cause the driver to stop
>> responding, report an error (as below)
>> and the machine to "hang" for about 20 seconds. As others have mentioned, 
>> a
>> down/up of the interface will recover until it locks up again. The dmesg
>> output for me is usually something like:
>>
>> sky2 eth1: tx timeout
>> sky2 eth1: transmit ring 397 .. 356 report=399 done 399
>> sky2 status report lost?
>>
>> I have also tried the new transmit code that was supplied earlier in this
>> thread without improvement of this situation.
>>
>> Any help appreciated.,
>>
>
> Are you running ipv6?  there was just a fix where ipv6 was sending
> the hardware bad data?
>
> -- 
> Stephen Hemminger <shemminger@osdl.org>

No, IPv4.. looks like this is a different issue.. Can I supply any data to 
help solve this issue?

