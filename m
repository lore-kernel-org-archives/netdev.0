From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: TSO on veth device slows transmission to a crawl
Date: Thu, 9 Apr 2015 17:35:59 +0200 (CEST)
Message-ID: <alpine.LSU.2.20.1504091731410.14110@nerf40.vanv.qr>
References: <alpine.LSU.2.20.1504070014250.21650@nerf40.vanv.qr>  <1428374918.25985.206.camel@edumazet-glaptop2.roam.corp.google.com>  <alpine.LSU.2.20.1504071149280.31930@nerf40.vanv.qr>  <1428436189.25985.211.camel@edumazet-glaptop2.roam.corp.google.com>
  <alpine.LSU.2.20.1504081844390.6502@nerf40.vanv.qr>  <1428571471.25985.246.camel@edumazet-glaptop2.roam.corp.google.com>  <alpine.LSU.2.20.1504091127310.24030@nerf40.vanv.qr> <1428592109.25985.249.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares41.inai.de ([46.4.122.207]:59735 "EHLO ares41.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753014AbbDIPgB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 11:36:01 -0400
In-Reply-To: <1428592109.25985.249.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thursday 2015-04-09 17:08, Eric Dumazet wrote:
>> >
>> >Basic IP routing seems not properly enabled, as even ping does not work
>> >to reach 10.10.23.23
>> 
>> Since I have net.ipv4.conf.all.forwarding,net.ipv4.ip_forward=1
>> this probably got inherited into the containers, so I did not
>> write it down into the scripts.
>> Enable it :)
>
>The thing is : It is enabled.

If forwarding is on, and the config is reasonably correct (which
I think it is), and it still won't ping, then would that not mean
there is another bug in the kernel?

>> >Have you tried net-next as well ?
>> 
>> I have now - a quick test yields no problem. Next I will do a reverse 
>> bisect just for the fun.
>
>Cool ;)

I've aborted the search. v4.0-rc crashes in a VM
http://marc.info/?l=linux-kernel&m=142850643415538&w=2 , and on a
real system, the SCSI layer similarly acts up in 4.0rc5 such that sda
won't even show up in the first place. If large portions of the
history don't be booted, I can't bisect it.
