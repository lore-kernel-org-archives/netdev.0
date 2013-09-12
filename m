From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: sctp: fix ipv6 ipsec encryption bug in
 sctp_v6_xmit
Date: Thu, 12 Sep 2013 17:26:40 -0400 (EDT)
Message-ID: <20130912.172640.1787268200692982351.davem@davemloft.net>
References: <1378911516-15942-1-git-send-email-dborkman@redhat.com>
	<52308C88.10604@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, adobriyan@gmail.com,
	steffen.klassert@secunet.com, hannes@stressinduktion.org
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38894 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757186Ab3ILV0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 17:26:43 -0400
In-Reply-To: <52308C88.10604@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevich@gmail.com>
Date: Wed, 11 Sep 2013 11:30:16 -0400

> On 09/11/2013 10:58 AM, Daniel Borkmann wrote:
>> Alan Chester reported an issue with IPv6 on SCTP that IPsec traffic is
>> not
>> being encrypted, whereas on IPv4 it is. Setting up an AH + ESP
>> transport
>> does not seem to have the desired effect:
...
>> Reported-by: Alan Chester <alan.chester@tekelec.com>
>> Reported-by: Alexey Dobriyan <adobriyan@gmail.com>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> Cc: Steffen Klassert <steffen.klassert@secunet.com>
>> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> 
> Acked-by: Vlad Yasevich <vyasevich@gmail.com>

Applied and queued up for -stable, thanks.

Yeah it is tricky to share a common transmit path with the
way SCTP works.
