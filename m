From: Alexey Gladkov <gladkov.alexey@gmail.com>
Subject: Re: [RFD] Network configuration data in sysfs
Date: Tue, 25 Oct 2011 03:54:03 +0400
Message-ID: <4EA5FA9B.5050908@gmail.com>
References: <20111024013406.GA24158@shutemov.name> <20111023.232416.1038111296509565828.davem@davemloft.net> <20111024042400.GA31344@shutemov.name> <20111024.005900.1091819103500072631.davem@davemloft.net> <CAPXgP10PZU+xSbQW-CH-E5rCk3-=1k-AvAs=tF8fAnz7QsmJRw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kirill@shutemov.name,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, gregkh@suse.de
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mojo.unsafe.ru ([83.222.2.183]:5908 "EHLO mojo.unsafe.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754720Ab1JYAQo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Oct 2011 20:16:44 -0400
In-Reply-To: <CAPXgP10PZU+xSbQW-CH-E5rCk3-=1k-AvAs=tF8fAnz7QsmJRw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

24.10.2011 16:46, Kay Sievers wrote:
> Kirill, what exactly is the use case? And why what does udev support
> mean in that context?
> 
> I doubt that "not having /sbin/ip installed" should be a reason to add
> and expose complex interfaces in /sys, while we already have a
> perfectly working native way to do it.

Adding NETLINK_ROUTE in udev is a way to perform some actions in case
of network events without polling. Now there are only a few specific
daemons (NM, connman etc) that are listen to the netlink socket and
setup the network his own way.

-- 
Rgrds, legion
