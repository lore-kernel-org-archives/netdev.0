From: Rabeeh Khoury <rabeeh@galileo.co.il>
Subject: Linux IP stack on kernel 2.4.18
Date: Sun, 02 Jun 2002 11:56:48 +0300
Sender: owner-netdev@oss.sgi.com
Message-ID: <3CF9DDD0.3080809@galileo.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi All,

I'm using kernel 2.4.18 and developing an ethernet network interface driver.
I have two problems that if you may consult me how to solve them -

1.. How can I adjust the throttling parameter of the IP stack not to drop any packet ? Meantime the IP stack routes 55k packets/sec and all the other it just drops (I can see them by the result of netif_rx).
2.. Routing jumbo packets through IP stack - I send 9K packets in size and IP stack routes the packets but by sending 1K packets in size ! is this possible ? I tripple checked the device driver on receive and transmit and it's ok. Do you know what is the problem ?


Thank you alot,
Rabeeh
