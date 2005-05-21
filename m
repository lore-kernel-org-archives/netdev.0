From: Michael Renzmann <netdev@nospam.otaku42.de>
Subject: Network driver behaviour when loosing link
Date: Sat, 21 May 2005 22:05:48 +0200
Message-ID: <428F949C.8080707@otaku42.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all.

I'm playing with a network driver and came across one thing I'd like to 
ask something about.

Let's assume a driver detects a link status change (for example, the 
link is dropped). I would have expected that the driver should signal 
the change via netif_carrier_on/_off (if used at all) and tell the 
kernel to stop/resume sending packets to the driver (via 
netif_wake_queue/netif_stop_queue).

When checking several drivers I found some that call 
netif_[wake|stop]_queue (e100, e1000), while others don't (natsemi, tg3).

Hence the question: what is the recommended behaviour in such a case? Is 
it ok to call netif_[stop|wake]_queue? How about adjusting the 
IFF_RUNNING flag accordingly? Is there any documentation available on 
this topic?

Thanks in advance.

Bye, Mike
