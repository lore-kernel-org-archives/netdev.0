From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net v2 2/2] ipv6/udp: use sticky pktinfo egress ifindex on
 connect()
Date: Mon, 1 Feb 2016 19:06:15 -0700
Message-ID: <56B00F17.7050007@cumulusnetworks.com>
References: <cover.1454066754.git.pabeni@redhat.com>
 <f5da7436f794a624fd050130953de7a5d85b31ff.1454066754.git.pabeni@redhat.com>
 <56AB5C37.7020604@stressinduktion.org> <56AEC187.1060308@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org,
	David Ahern <dsa@cumulusnetworks.com>,
	Hajime Tazaki <thehajime@gmail.com>, lucien.xin@gmail.com,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:32841 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751728AbcBBCGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 21:06:21 -0500
Received: by mail-ob0-f174.google.com with SMTP id is5so136828573obc.0
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 18:06:20 -0800 (PST)
In-Reply-To: <56AEC187.1060308@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/31/16 7:23 PM, YOSHIFUJI Hideaki wrote:
>
>
> Hannes Frederic Sowa wrote:
>> On 29.01.2016 12:30, Paolo Abeni wrote:
>>> Currently, the egress interface index specified via IPV6_PKTINFO
>>> is ignored by __ip6_datagram_connect(), so that RFC 3542 section 6.7
>>> can be subverted when the user space application calls connect()
>>> before sendmsg().
>>> Fix it by initializing properly flowi6_oif in connect() before
>>> performing the route lookup.
>>>
>>> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
>>
>> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>>
>>
>
> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>

Dave:

Can you queue these up for 4.4 stable? Fixes 'ping6 -I <interface>' for 
VRFs and 4.4 is the first release with VRF for IPv6.

Thanks,

David
