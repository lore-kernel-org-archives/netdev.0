From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: libmnl limitation...
Date: Sun, 20 Feb 2011 23:31:42 +0100
Message-ID: <4D61964E.3090705@netfilter.org>
References: <20110220.134128.115926805.davem@davemloft.net> <4D6194C2.5020202@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45190 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754719Ab1BTWbq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Feb 2011 17:31:46 -0500
In-Reply-To: <4D6194C2.5020202@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/02/11 23:25, Pablo Neira Ayuso wrote:
> On 20/02/11 22:41, David Miller wrote:
>>
>> Unfortunately, libmnl only allows setting socket options
>> that are of SOL_NETLINK.
>>
>> This precludes setting socket options such as SO_ATTACH_FILTER
>> which need to be of level SOL_SOCKET.
>>
>> It seems to be a mistake to have hard-coded the socket level
>> instead of simply letting the user specify it :-/
> 
> Indeed, I'm going to obsolete the current function and provide a new
> one. Sorry.

Actually, we can obsolete mnl_setsockopt(...), which is silly BTW, and
we can use mnl_socket_get_fd(...) with setsockopt(...).
