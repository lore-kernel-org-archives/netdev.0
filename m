From: Andy Zhou <azhou@nicira.com>
Subject: Re: [net-next 1/6] net: Add Geneve tunneling protocol driver
Date: Fri, 3 Oct 2014 12:45:40 -0700
Message-ID: <CACzMAJJV8=B7N_JMBOA3C8XhpVw8GJR23FAQtWj8iHQFpbmx1A@mail.gmail.com>
References: <1412237085-27215-1-git-send-email-azhou@nicira.com>
	<1412237085-27215-2-git-send-email-azhou@nicira.com>
	<542EA847.4000904@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jesse Gross <jesse@nicira.com>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aob139.obsmtp.com ([74.125.149.251]:47506 "HELO
	psmtp.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753862AbaJCTpn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 15:45:43 -0400
Received: by mail-oi0-f42.google.com with SMTP id a141so1271458oig.29
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 12:45:40 -0700 (PDT)
In-Reply-To: <542EA847.4000904@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Do you plan too add the full support (ie being able to configure a
> geneve netdev interface with iproute2)?
>
According to the following email thread, John Linville is looking at adding it.
http://lists.openwall.net/netdev/2014/07/22/198

> Another small comment below.
>
>> +config GENEVE
>> +       tristate "Generic Network Virtualization Encapsulation (Geneve)"
>> +       depends on INET
>> +       select NET_IP_TUNNEL
>> +       select NET_UDP_TUNNEL
>> +       ---help---
>
> Use tabs instead of spaces for the baove lines.

Sure, I will fix this.
