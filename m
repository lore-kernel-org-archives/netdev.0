From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH net-next] IPv6: enable bind() to assign an anycast address
Date: Fri, 10 Jan 2014 14:01:22 -0800 (PST)
Message-ID: <1389391282.61382.YahooMailBasic@web125501.mail.ne1.yahoo.com>
References: <20140110205100.GB23647@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm46.bullet.mail.ne1.yahoo.com ([98.138.120.53]:30769 "EHLO
	nm46.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751343AbaAJWEF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 17:04:05 -0500
In-Reply-To: <20140110205100.GB23647@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 1/10/14, Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

>On Fri, Jan 10, 2014 at 07:12:24PM +0100, Francois-Xavier Le Bail wrote:
>> - Add ipv6_chk_acast_addr_src() to check if an anycast address is link-local
>>   on given interface or is global (on any interface).
>> - Use it in inet6_bind().
>> 
>> Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
>> ---
>> Tested with link-local and global anycast addresses.
>> Tested with SOCK_DGRAM socket, bind and UDP traffic OK.
>>
>> Tested with SOCK_STREAM socket, bind OK, traffic need another change.

> What do you mean with that?

In actual TCP code, if the destination address is not unicast, the request is dropped:

	if (!ipv6_unicast_destination(skb))
		goto drop;

I will send another patch to allow anycat addresses destinations fot TCP. 

bye,
Francois-Xavier
