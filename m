From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH net v2 2/2] ipv6/udp: use sticky pktinfo egress ifindex on
 connect()
Date: Mon, 1 Feb 2016 11:23:03 +0900
Message-ID: <56AEC187.1060308@miraclelinux.com>
References: <cover.1454066754.git.pabeni@redhat.com>
 <f5da7436f794a624fd050130953de7a5d85b31ff.1454066754.git.pabeni@redhat.com>
 <56AB5C37.7020604@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Hajime Tazaki <thehajime@gmail.com>, lucien.xin@gmail.com,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34167 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933509AbcBACXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jan 2016 21:23:07 -0500
Received: by mail-pf0-f172.google.com with SMTP id o185so69859772pfb.1
        for <netdev@vger.kernel.org>; Sun, 31 Jan 2016 18:23:06 -0800 (PST)
In-Reply-To: <56AB5C37.7020604@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Hannes Frederic Sowa wrote:
> On 29.01.2016 12:30, Paolo Abeni wrote:
>> Currently, the egress interface index specified via IPV6_PKTINFO
>> is ignored by __ip6_datagram_connect(), so that RFC 3542 section 6.7
>> can be subverted when the user space application calls connect()
>> before sendmsg().
>> Fix it by initializing properly flowi6_oif in connect() before
>> performing the route lookup.
>>
>> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> 
> 

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
