From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Re: Lost packets after switching Wi-Fi AP
Date: Tue, 31 Oct 2006 09:46:19 +0100
Message-ID: <45470D5B.5010105@bull.net>
References: <4546127D.10403@bull.net> <20061030211923.79292f8d@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:4807 "EHLO
	ecfrec.frec.bull.fr") by vger.kernel.org with ESMTP
	id S1422881AbWJaInA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Oct 2006 03:43:00 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061030211923.79292f8d@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Benc wrote:
> On Mon, 30 Oct 2006 15:55:57 +0100, Benjamin Thery wrote:
>> When I switch my Mobile Node between 2 Wi-Fi Access Points, there is a 
>> period of time where all the packets I send are lost, although I got 
>> the netlink event SIOCGIWAP 'up' for the new AP. The device is 
>> supposed to be ready, but the packets are lost.
> 
> Which wireless card are you using? Which version of the kernel?

Hi Jiri,

The kernel version is 2.6.16.20 (the latest kernel version officially 
supported by MIPv6). I'd like to use a 2.6.19 but unfortunately not 
all the IPv6 mobility patches are in.

I reproduced the problem with an Intel Pro Wireless 2200 (latest 
driver version: 1.2.0) and a pcmcia "D-Link Airplus G+ DWL-G650+" 
using the ndiswrapper version 1.25.

But I'm not sure the problem is wireless-specific.

And as I wrote in my first message I'm also surprised that when 
noop_enqueue() is used, the return code is NET_XMIT_CN, whereas the 
packet seems to be dropped.

Thanks for your help.

Benjamin

>  Jiri
> 


-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
