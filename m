From: Jeff Garzik <jeff@garzik.org>
Subject: Re: reminder, 2.6.18 window...
Date: Wed, 24 May 2006 14:23:05 -0400
Message-ID: <4474A489.4080308@garzik.org>
References: <20060523.182217.59656237.davem@davemloft.net> <447412CA.50303@ipom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56200 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932449AbWEXSXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 14:23:09 -0400
To: Phil Dibowitz <phil@ipom.com>
In-Reply-To: <447412CA.50303@ipom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Phil Dibowitz wrote:
> David Miller wrote:
>> Some time in the next few weeks, it is likely that the 2.6.18
>> merge window will open up shortly after a 2.6.17 release.
>>
>> So if you have major 2.6.18 submissions planned for the networking,
>> you need to start thinking about getting it to me now.
>>
>> There is a 2.6.18 tree up at:
>>
>> master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.18.git
>>
>> All it has right now is the I/O AT stuff at the moment, and I plan to
>> put Stephen Hemminger's LLC multicast/datagram changes in there as
>> well.
> 
> David,
> 
> I posted a patch for adding support for network device statistic
> resetting via ethtool. I saw no objections to it... it impliments the
> framework as well as skge support, so it touches both your and Jeff's area.
> 
> For your reference, here's the two times I've posted it this month - I'm
> happy to send it along again.
> 
> 2006-05-18
> RESEND: [PATCH] Interface Stat Clearing Framework, skge support, ethtool
> http://marc.theaimsgroup.com/?l=linux-netdev&m=114794065502155&w=2
> 
> 2006-04-30
> [PATCH] Interface Stat Clearing Framework, skge support, ethtool
> http://marc.theaimsgroup.com/?l=linux-netdev&m=114636704207480&w=2

I disagree that we should bother about clearing statistics.  It always 
adds more complication than necessary.  Few (if any) other statistics in 
Linux permit easy clearing, often because adding operations other than 
'increment' or 'read' requires adding expensive spinlocks or atomic 
operations.

	Jeff



