From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv6: add tokenized interface identifier
 support
Date: Mon, 08 Apr 2013 16:57:58 -0400 (EDT)
Message-ID: <20130408.165758.621291267677314731.davem@davemloft.net>
References: <1365429690-17342-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	yoshfuji@linux-ipv6.org, tgraf@suug.ch
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52885 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964998Ab3DHU6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 16:58:00 -0400
In-Reply-To: <1365429690-17342-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon,  8 Apr 2013 16:01:30 +0200

> This patch adds support for IPv6 tokenized IIDs, that allow
> for administrators to assign well-known host-part addresses
> to nodes whilst still obtaining global network prefix from
> Router Advertisements. It is currently in draft status.
> 
>   The primary target for such support is server platforms
>   where addresses are usually manually configured, rather
>   than using DHCPv6 or SLAAC. By using tokenised identifiers,
>   hosts can still determine their network prefix by use of
>   SLAAC, but more readily be automatically renumbered should
>   their network prefix change. [...]
> 
>   The disadvantage with static addresses is that they are
>   likely to require manual editing should the network prefix
>   in use change.  If instead there were a method to only
>   manually configure the static identifier part of the IPv6
>   address, then the address could be automatically updated
>   when a new prefix was introduced, as described in [RFC4192]
>   for example.  In such cases a DNS server might be
>   configured with such a tokenised interface identifier of
>   ::53, and SLAAC would use the token in constructing the
>   interface address, using the advertised prefix. [...]
> 
>   http://tools.ietf.org/html/draft-chown-6man-tokenised-ipv6-identifiers-02
> 
> The implementation is partially based on top of Mark K.
> Thompson's proof of concept. However, it uses the Netlink
> interface for configuration resp. data retrival, so that
> it can be easily extended in future. Successfully tested
> by myself.
> 
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Cc: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
