From: Rabeeh Khoury <rabeeh@galileo.co.il>
Subject: Re: Linux IP stack on kernel 2.4.18
Date: Sun, 02 Jun 2002 20:11:22 +0300
Sender: owner-netdev@oss.sgi.com
Message-ID: <3CFA51BA.1000202@galileo.co.il>
References: <Pine.GSO.4.05.10206021139290.6283-100000@mausmaki.cosy.sbg.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: "Thomas 'Dent' Mirlacher" <dent@cosy.sbg.ac.at>
List-Id: netdev.vger.kernel.org



Thomas 'Dent' Mirlacher wrote:

>--snip/snip
>
>  
>
>>2.. Routing jumbo packets through IP stack - I send 9K packets in size and IP stack routes the packets but by sending 1K packets in size ! is this possible ? I tripple checked the device driver on receive and transmit and it's ok. Do you know what is the problem ?
>>    
>>
>
>did you check you MTU?
>
sh-2.04# ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 64:41:40:12:12:31 
          inet addr:10.2.40.130  Bcast:10.2.255.255  Mask:255.255.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:9700  Metric:1
          RX packets:5668 errors:0 dropped:0 overruns:0 frame:0
          TX packets:3280 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:4787563 (4.5 Mb)  TX bytes:543741 (530.9 Kb)
          Interrupt:32

>
>	tm
>
>  
>
