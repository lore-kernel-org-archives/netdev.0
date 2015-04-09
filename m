From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: TSO on veth device slows transmission to a crawl
Date: Thu, 9 Apr 2015 12:26:32 +0200 (CEST)
Message-ID: <alpine.LSU.2.20.1504091127310.24030@nerf40.vanv.qr>
References: <alpine.LSU.2.20.1504070014250.21650@nerf40.vanv.qr>  <1428374918.25985.206.camel@edumazet-glaptop2.roam.corp.google.com>  <alpine.LSU.2.20.1504071149280.31930@nerf40.vanv.qr>  <1428436189.25985.211.camel@edumazet-glaptop2.roam.corp.google.com>
  <alpine.LSU.2.20.1504081844390.6502@nerf40.vanv.qr> <1428571471.25985.246.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares41.inai.de ([46.4.122.207]:58905 "EHLO ares41.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755112AbbDIK0d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 06:26:33 -0400
In-Reply-To: <1428571471.25985.246.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thursday 2015-04-09 11:24, Eric Dumazet wrote:
>> I was finally able to reproduce it reliably, and with just one 
>> machine/kernel instance (and a number of containers of course).
>> 
>> I have uploaded the script mix to
>> 	http://inai.de/files/tso-1.tar.xz
>> There is a demo screencast at
>> 	http://inai.de/files/tso-1.mkv
>
>Thanks for providing these scripts, but they do not work on my host
>running latest net-next
>
>Basic IP routing seems not properly enabled, as even ping does not work
>to reach 10.10.23.23

Since I have net.ipv4.conf.all.forwarding,net.ipv4.ip_forward=1
this probably got inherited into the containers, so I did not
write it down into the scripts.
Enable it :)

>Have you tried net-next as well ?

I have now - a quick test yields no problem. Next I will do a reverse 
bisect just for the fun.
