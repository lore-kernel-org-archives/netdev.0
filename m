From: David Miller <davem@davemloft.net>
Subject: Re: libmnl limitation...
Date: Sun, 20 Feb 2011 14:38:25 -0800 (PST)
Message-ID: <20110220.143825.246503396.davem@davemloft.net>
References: <20110220.134128.115926805.davem@davemloft.net>
	<4D6194C2.5020202@netfilter.org>
	<4D61964E.3090705@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38989
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754197Ab1BTWht (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Feb 2011 17:37:49 -0500
In-Reply-To: <4D61964E.3090705@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Sun, 20 Feb 2011 23:31:42 +0100

> On 20/02/11 23:25, Pablo Neira Ayuso wrote:
>> On 20/02/11 22:41, David Miller wrote:
>>>
>>> Unfortunately, libmnl only allows setting socket options
>>> that are of SOL_NETLINK.
>>>
>>> This precludes setting socket options such as SO_ATTACH_FILTER
>>> which need to be of level SOL_SOCKET.
>>>
>>> It seems to be a mistake to have hard-coded the socket level
>>> instead of simply letting the user specify it :-/
>> 
>> Indeed, I'm going to obsolete the current function and provide a new
>> one. Sorry.
> 
> Actually, we can obsolete mnl_setsockopt(...), which is silly BTW, and
> we can use mnl_socket_get_fd(...) with setsockopt(...).

Sure.
