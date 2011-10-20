From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: allow CAP_NET_RAW to set socket options
 IP{,V6}_TRANSPARENT
Date: Thu, 20 Oct 2011 18:22:14 -0400 (EDT)
Message-ID: <20111020.182214.629562655202957174.davem@davemloft.net>
References: <20111020.003458.1034042223691970343.davem@davemloft.net>
	<1319148614-6739-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: maze@google.com, netdev@vger.kernel.org
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49951 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751244Ab1JTWWU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 18:22:20 -0400
In-Reply-To: <1319148614-6739-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Thu, 20 Oct 2011 15:10:14 -0700

> From: Maciej =AFenczykowski <maze@google.com>
>=20
> Up till now the IP{,V6}_TRANSPARENT socket options (which actually se=
t
> the same bit in the socket struct) have required CAP_NET_ADMIN
> privileges to set or clear the option.
>=20
> - we make clearing the bit not require any privileges.
> - we allow CAP_NET_ADMIN to set the bit (as before this change)
> - we allow CAP_NET_RAW to set this bit, because raw
>   sockets already pretty much effectively allow you
>   to emulate socket transparency.
>=20
> Signed-off-by: Maciej =AFenczykowski <maze@google.com>

Applied, thanks.
