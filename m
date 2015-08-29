From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] sctp: ASCONF-ACK with Unresolvable Address
 should be sent
Date: Fri, 28 Aug 2015 22:26:11 -0700 (PDT)
Message-ID: <20150828.222611.1146631151814575971.davem@davemloft.net>
References: <bf1cc62ac51821f36b0e195fa610544d7c4808d7.1440755158.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mleitner@redhat.com, vyasevic@redhat.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58272 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533AbbH2F0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2015 01:26:12 -0400
In-Reply-To: <bf1cc62ac51821f36b0e195fa610544d7c4808d7.1440755158.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Fri, 28 Aug 2015 17:45:58 +0800

> RFC 5061:
>     This is an opaque integer assigned by the sender to identify each
>     request parameter.  The receiver of the ASCONF Chunk will copy this
>     32-bit value into the ASCONF Response Correlation ID field of the
>     ASCONF-ACK response parameter.  The sender of the ASCONF can use this
>     same value in the ASCONF-ACK to find which request the response is
>     for.  Note that the receiver MUST NOT change this 32-bit value.
> 
>     Address Parameter: TLV
> 
>     This field contains an IPv4 or IPv6 address parameter, as described
>     in Section 3.3.2.1 of [RFC4960].
> 
> ASCONF chunk with Error Cause Indication Parameter (Unresolvable Address)
> should be sent if the Delete IP Address is not part of the association.
> 
>   Endpoint A                           Endpoint B
>   (ESTABLISHED)                        (ESTABLISHED)
> 
>   ASCONF        ----------------->
>   (Delete IP Address)
>                 <-----------------      ASCONF-ACK
>                                         (Unresolvable Address)
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.
