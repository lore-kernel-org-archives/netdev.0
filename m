From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [Lksctp-developers] Fw: Intermittent SCTP multihoming breakage
Date: Mon, 05 Feb 2007 12:07:39 -0500
Message-ID: <45C7645B.7070009@hp.com>
References: <E096369D937D3A4DB271B382850C5C5F44E657@pysmail.eicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Sridhar Samudrala <sri@us.ibm.com>
To: Steve Hill <steve.hill@dialogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:59665 "EHLO mailhub.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751860AbXBERHm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 12:07:42 -0500
In-Reply-To: <E096369D937D3A4DB271B382850C5C5F44E657@pysmail.eicon.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Steve

Steve Hill wrote:
> Vlad Yasevich wrote on 05 February 2007 16:39:
> 
>> Once you start simulating the network failure, how long do you wait?
>>
>> If you have not changed rto_max and path_max_retrans, you can end up
>> waiting quite a while for the full path switchover.  This will also
>> severely slow down your retransmissions...
> 
> I'm waiting several minutes, and I'm using setsockopt() to set the
> timeouts fairly low:
> 	srto_initial = 1000ms
> 	srto_min = 200ms
> 	srto_max = 1400ms
> 	spp_pathmaxrxt = 2
> 	spp_hbinterval = 1000ms

Ok, thanks for the info.  Two more questions:

  1. What did you set the sinfo_timetolive to?
  2. What specific netfilter rule to do use to simulate network outage?
     I was using '-t filter -A INPUT -i eth0 -p sctp -j DROP'

Just trying to get more info to simulate this.  My prior attempts 
recovered quickly with my patch.

Thanks
-vlad

> 
> The network's round trip time (indicated by ping) is on the order of
> <0.25ms.
> 
>  - Steve Hill
>    Software Engineer
>    Dialogic
>    Fordingbridge, Hampshire, UK
>    +44-1425-651392
>    steve.hill@dialogic.com
> 

