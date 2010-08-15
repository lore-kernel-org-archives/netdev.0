From: Morgon.J.Kanter@Dartmouth.edu
Subject: Re: PROBLEM: raw sockets rewriting IP ID in rare cases.
Date: Sun, 15 Aug 2010 13:57:41 -0400
Message-ID: <20100815135741.1iud2jvgw0wwg4kw@webmail.dartmouth.edu>
References: <201008131307.38381.morgon.j.kanter@dartmouth.edu>
	<20100814.223532.242143460.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-1;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spruis.dartmouth.edu ([129.170.208.37]:47907 "EHLO
	spruis.dartmouth.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739Ab0HOSHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Aug 2010 14:07:16 -0400
In-Reply-To: <20100814.223532.242143460.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting David Miller <davem@davemloft.net>:
>> I have stumbled across what I think is a rare bug in the raw socket  
>>  mechanism
>> of the kernel. When attempting to send a certain packet with an IP   
>> ID of zero
>> from a raw socket created with the call "socket(AF_INET, SOCK_RAW,
>> IPPROTO_RAW)", the kernel will modify the IP ID field and update   
>> the checksum.
>> It only seems to do it with this specific packet for some reason, similar
>> packets with an IP ID of zero do not get so mangled.
>
> Even when using hdrinclude mode of RAW ipv4 sockets, if you specify
> a zero ID field, the kernel will fill it in with the usual value.
>
> It is expected behavior.
>
> If you want the kernel to leave your ID field alone, provide a
> non-zero one.

Is there a way to turn this behavior off, then, with raw sockets? Zero  
is the desired ID value.

Thanks,
-- Morgon
