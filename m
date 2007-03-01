From: Marc D Ronell <mronell@alumni.upenn.edu>
Subject: Re: Network access fails unless tcpdump is running?
Date: Thu, 01 Mar 2007 18:27:18 -0500
Message-ID: <87hct44ka1.fsf@corps.glidepath.invalid>
References: <87y7mg4vm7.fsf@corps.glidepath.invalid> <20070301201307.GC3199@gospo.rdu.redhat.com>
 <87ps7s4rbx.fsf@corps.glidepath.invalid>
 <20070301212245.GD3199@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:42487 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161180AbXCAXq1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2007 18:46:27 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1HMuqh-0001yU-GI
	for netdev@vger.kernel.org; Fri, 02 Mar 2007 00:38:11 +0100
Received: from pool-71-255-169-178.bstnma.east.verizon.net ([71.255.169.178])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 02 Mar 2007 00:38:11 +0100
Received: from mronell by pool-71-255-169-178.bstnma.east.verizon.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 02 Mar 2007 00:38:11 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gospodarek <andy@greyhouse.net> writes:

> On Thu, Mar 01, 2007 at 03:54:58PM -0500, Marc D Ronell wrote:
>> Andy Gospodarek <andy@greyhouse.net> writes:
>> 
>> > On Thu, Mar 01, 2007 at 02:22:24PM -0500, Marc D Ronell wrote:
>> >> 
>> >> Hi,
>> >> 
>> >> I can not ping a remote host successfully unless I have "tcpdump -i
>> >> eth0" running, in which case, my network access works fine.  
>> >
>> > Interesting that when your interface is in promiscious mode it works
>> > fine, but otherwise it doesn't.  Do you have all of your iptables rules
>> > cleared?
>> >
>> 
>> Thanks very  much for  your reply  and interest.  I  find this  an odd
>> problem.  The output of iptables -L looks like:
>> 
>>    caviar:/tmp# iptables -L
>>    Chain INPUT (policy ACCEPT)
>>    target     prot opt source               destination         
>> 
>>    Chain FORWARD (policy ACCEPT)
>>    target     prot opt source               destination         
>> 
>>    Chain OUTPUT (policy ACCEPT)
>>    target     prot opt source               destination         
>> 
>> The  machine name  is caviar  on the  prompt.  There  are no  rules in
>> place.  AFAIK,  there are no firewalls running.   Changing the routing
>> table did not help the situation.  
>> 
>
> Looks good.
>
>> 
>> >> I am  running Debian etch on  a Dell Inspiron e1505  laptop.  The eth0
>> >> address  is static  on my  local LAN.   Once tcpdump  is  running, the
>> >> laptop can access the network with no problems.
>> >
>> > What networking hardware is on that laptop?  Can you post the complete
>> > output of `ethtool -i eth0` and the network device info from the output
>> > of `lcpci -vvv`?
>> 
>> lspci output is attached below.
>> 
>
> I presumed this is with the wired interface (not the wireless one).
> That is a correct assumption, right?
>
Thats correct. Its the wired interface, eth0 which is having the
problem.  I have turned the wireless interface, eth2 off with both
ifconfig and ifdown, and still, the connection to the outside only
works when tcpdump is running.

> Can you post the output from `ethtool -i ethX` (where ethX is the wired
> interface).  I ask because that tells me what version of the b44/ipw3945
> driver you are using.
>
>

# ethtool -i eth0
driver: b44
version: 1.01
firmware-version:
bus-info: 0000:03:00.0


The system was working originally fine, but something changed.
Perhaps through an Debian aptitude update.

Thanks for your help and interest.

marc

