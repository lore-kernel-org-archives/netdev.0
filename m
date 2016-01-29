From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net v2 2/2] ipv6/udp: use sticky pktinfo egress ifindex on
 connect()
Date: Fri, 29 Jan 2016 13:33:59 +0100
Message-ID: <56AB5C37.7020604@stressinduktion.org>
References: <cover.1454066754.git.pabeni@redhat.com>
 <f5da7436f794a624fd050130953de7a5d85b31ff.1454066754.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Hajime Tazaki <thehajime@gmail.com>, lucien.xin@gmail.com,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:36716 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755072AbcA2MeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 07:34:03 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 43B56205FC
	for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 07:34:03 -0500 (EST)
In-Reply-To: <f5da7436f794a624fd050130953de7a5d85b31ff.1454066754.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29.01.2016 12:30, Paolo Abeni wrote:
> Currently, the egress interface index specified via IPV6_PKTINFO
> is ignored by __ip6_datagram_connect(), so that RFC 3542 section 6.7
> can be subverted when the user space application calls connect()
> before sendmsg().
> Fix it by initializing properly flowi6_oif in connect() before
> performing the route lookup.
>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
