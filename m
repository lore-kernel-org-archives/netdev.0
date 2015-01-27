From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: Does arping update arp table?
Date: Tue, 27 Jan 2015 16:12:13 -0500
Message-ID: <54C7FF2D.8000603@ti.com>
References: <54C7E5B5.8060401@ti.com> <54C7F930.6090506@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:56970 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755888AbbA0VMP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2015 16:12:15 -0500
In-Reply-To: <54C7F930.6090506@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/27/2015 03:46 PM, David Ahern wrote:
> On 1/27/15 12:23 PM, Murali Karicheri wrote:
>> However this command doesn't update the arp table on my Keystone EVM
>> based on v3.19.x and also newer ubuntu machine based on v3.11. Is this
>> expected behavior? I believe the arp response resulting from a arping
>> command is controlled through per interface accept sys control like as
>> in gratuitous arp. Please repond.
>
> echo 1 > /proc/sys/net/ipv4/conf/eth0/arp_accept
>

Thanks. That is what I thought.

-- 
Murali Karicheri
Linux Kernel, Texas Instruments
