From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: LRO restructuring?
Date: Tue, 12 Aug 2008 07:50:58 -0400
Message-ID: <48A17922.4050103@myri.com>
References: <48A03EF9.9090602@myri.com> <20080811.140351.54834488.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org, brice@myri.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1922 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752172AbYHLLvf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Aug 2008 07:51:35 -0400
In-Reply-To: <20080811.140351.54834488.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Andrew Gallatin <gallatin@myri.com>
> Date: Mon, 11 Aug 2008 09:30:33 -0400
> 
>> Last, have you considered simply allowing "inexact" forwarding, where
>> the ingress NIC is doing LRO and the egress nic is doing TSO?  You
>> loose exact framing information (eg, what you emit might not be framed
>> exactly as you receive it), but you can still do filtering, and the
>> host overhead is very low.
> 
> Intermediate nodes are not supposed to change the transport layer
> checksum if at all possible, especially on routers.

Indeed.  Nor should they change lengths, or anything else.
Everything about this "inexact" forwarding is illegal as
hell.  However, you have to admit that it is an interesting hack :)

Drew
