From: James Turner <jturner@gemini.edu>
Subject: Re: [2.6.10-rc1-bk5] e1000 broken badly on IBM T42
Date: Sun, 14 Nov 2004 17:25:42 -0300
Message-ID: <4197BF46.8060802@gemini.edu>
References: <200410270033.22804.shawn.starr@rogers.com> <200410270054.30313.shawn.starr@rogers.com> <200410270521.56816.shawn.starr@rogers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Shawn Starr <shawn.starr@rogers.com>
In-Reply-To: <200410270521.56816.shawn.starr@rogers.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>On October 27, 2004 00:33, Shawn Starr wrote:
>
>>NETDEV WATCHDOG: eth0: transmit timed out
>>e1000: eth0: e1000_watchdog: NIC Link is Up 1000 Mbps Full Duplex
>>NETDEV WATCHDOG: eth0: transmit timed out
>>
>>eth0      Link encap:Ethernet  HWaddr 00:0D:60:CA:C1:97
>>          inet addr:192.168.10.5  Bcast:192.168.10.255 
>>Mask:255.255.255.0 UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>>          RX packets:4294883167 errors:4294370903 dropped:4294796898
>>overruns:4294882097 frame:4294711699 TX packets:4294883949
>>errors:4294796898 dropped:0 overruns:0 carrier:4294711699
>>collisions:4294882097 txqueuelen:1000
>>          RX bytes:470309 (459.2 KiB)  TX bytes:108971 (106.4 KiB)
>>          Base address:0x8000 Memory:c0220000-c0240000

I also get 4bn errors reported using e1000 on a T42 (2378-DXU) after
coming out of APM suspend. However, my network interface seems to work
normally otherwise, as far as I can tell. It always reports 100Mbps.

eth0      Link encap:Ethernet  HWaddr 00:0D:60:FF:0D:9A
           inet addr:172.16.22.206  Bcast:172.16.22.255 Mask:255.255.255.0
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:887386 errors:4294967254 dropped:4294967284
overruns:4294967290 frame:4294967278
           TX packets:452521 errors:4294967284 dropped:0 overruns:0
carrier:4294967278
           collisions:4294967290 txqueuelen:1000
           RX bytes:1319970165 (1.2 GiB)  TX bytes:32622656 (31.1 MiB)
           Base address:0x8000 Memory:c0220000-c0240000

I'm using 2.6.9 (FC3), which includes e1000 version 5.3.19-k2. Looks
like there is a newer version at http://sourceforge.net/projects/e1000/
(maybe the same as in 2.6.10-rc1?).

James.

Please cc: any replies to me - thanks (IANAKH).
