From: "Ian Brown" <ianbrn@gmail.com>
Subject: ipv4_devconf.arp_accept mystery
Date: Sun, 23 Dec 2007 18:00:57 +0200
Message-ID: <d0383f90712230800n6e6d6b92x64eaa8dcff313915@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.241]:13310 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752045AbXLWQA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2007 11:00:59 -0500
Received: by an-out-0708.google.com with SMTP id d31so227022and.103
        for <netdev@vger.kernel.org>; Sun, 23 Dec 2007 08:00:57 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
I have a question regarding unsolicited ARPs in ipv4/arp.c

As I understand, by default this feature is disabled;
How can one set this feature ?

When working with ipv4_devconf.arp_accept is 0 by default.
This is with 2.6.21 kernel.

I wanted ipv4_devconf.arp_accept to be set to 1.

I added:
net.ipv4.conf.default.arp_accept = 1
net.ipv4.conf.eth0.arp_accept = 1
in /etc/sysctl.conf
and rebooted.

I have:
cat /proc/sys/net/ipv4/conf/default/arp_accept
=> 1
cat /proc/sys/net/ipv4/conf/eth0/arp_accept
=>1

Yet ,the printk() I added shows that ipv4_devconf.arp_accept shows 0 !!


Could it be that this variable could not be set ? or is it dependent
upon other things ?

BTW, in newer kernel version we have IPV4_DEVCONF_ALL(ARP_ACCEPT)
instead. So if anybody knows how to set this macro (instead)to be 1, it will be
also fine.


Ian
