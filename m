From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] add stealth mode
Date: Mon, 06 Jul 2015 19:34:56 -0700 (PDT)
Message-ID: <20150706.193456.1294570536559039749.davem@davemloft.net>
References: <CAFnufp059tojfKYBye4eayOCvNNkAE9w_s_6E-PiG-EYp9K0Gg@mail.gmail.com>
	<21611.1436179798@turing-police.cc.vt.edu>
	<CAFnufp3xP3xjd8zy0uLKEGgbBAb0motLva=f1EbMJCfcKG=Y-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Valdis.Kletnieks@vt.edu, nicolas.dichtel@6wind.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: matteo@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51226 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751289AbbGGCWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 22:22:38 -0400
In-Reply-To: <CAFnufp3xP3xjd8zy0uLKEGgbBAb0motLva=f1EbMJCfcKG=Y-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matteo Croce <matteo@openwrt.org>
Date: Mon, 6 Jul 2015 21:44:06 +0200

> 2015-07-06 12:49 GMT+02:00  <Valdis.Kletnieks@vt.edu>:
>> On Thu, 02 Jul 2015 10:56:01 +0200, Matteo Croce said:
>>> Add option to disable any reply not related to a listening socket,
>>> like RST/ACK for TCP and ICMP Port-Unreachable for UDP.
>>> Also disables ICMP replies to echo request and timestamp.
>>> The stealth mode can be enabled selectively for a single interface.
>>
>> A few notes.....
>>
>> 1) Do you have an actual use case where an iptables '-j DROP' isn't usable?
> 
> If you mean using a default DROP policy and allowing only the traffic
> do you want,
> then the use case is where the port can change at runtime and you may not want
> to update the firewall every time

Dynamically updated firewalls are "a thing" and quite effective for
solving problems like this one.

With nftables such updates are even extremely efficient.
