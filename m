From: Ankur Patel <ankur@embertec.com>
Subject: imx28evk: Ethernet Plug/Unplug Event not working
Date: Tue, 10 Jun 2014 14:09:48 +0930
Message-ID: <BD5E516FF3711A41B93DC005170007BB010D71B95FC0@EMBSVR01.ember.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.embertec.com ([119.18.44.70]:3320 "EHLO mail.embertec.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751835AbaFJEjz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 00:39:55 -0400
Received: from mail.embertec.com
	by embertec.com (mail.embertec.com)
	(SecurityGateway 2.0.6)
	with SMTP id SG000832207.MSG
	for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 14:09:52 +0930
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Friends,

I am using Linux kernel 3.10.32 on I.MX 28 EVK board. On that I couldn't able to get any netlink messages from kernel on Ethernet Plug/Unplug event.

I am using opensource program netlink.c (http://pastebin.com/CA8NThAS) to listen on all the netlink messages from kernel.

root@imx28evk:~# ./netlink
[   79.971113] libphy: 800f0000.etherne:00 - Link is Down
[   85.291482] libphy: 800f0000.etherne:00 - Link is Up - 100/Full
...

There is also udev rule defined as below which is not called: 
root@imx28evk:~# cat /etc/udev/rules.d/autonet.rules
# Handle network interface setup
SUBSYSTEM=="net", ACTION=="add" RUN+="/etc/udev/scripts/network.sh"
SUBSYSTEM=="net", ACTION=="remove" RUN+="/etc/udev/scripts/network.sh"

Could anyone share what I need to add to Ethernet driver to enable the kernel to send the messages?

Please share if you need more information.

Regards,
Ankur
