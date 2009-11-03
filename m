From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Support specifying the network namespace upon device
 creation.
Date: Tue, 03 Nov 2009 10:28:27 +0100
Message-ID: <4AEFF7BB.4090301@gmail.com>
References: <m1eioggeux.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:56052 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754749AbZKCJ2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 04:28:25 -0500
In-Reply-To: <m1eioggeux.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman a =E9crit :
> There is no good reason to not support userspace specifying the
> network namespace during device creation, and it makes it easier
> to create a network device and pass it to a child network namespace
> with a well known name.
>=20
> We have to be careful to ensure that the target network namespace
> for the new device exists through the life of the call.  To keep
> that logic clear I have factored out the network namespace grabbing
> logic into rtnl_link_get_net.
>=20
> In addtion we need to continue to pass the source network namespace
> to the rtnl_link_ops.newlink method so that we can find the base
> device source network namespace.
>=20
> Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>

Very nice, with only one long line you could wrap differently.
 =20
> -static int ipgre_newlink(struct net_device *dev, struct nlattr *tb[]=
,
> +static int ipgre_newlink(struct net *src_net, struct net_device *dev=
, struct nlattr *tb[],
>  			 struct nlattr *data[])
>  {
>  	struct ip_tunnel *nt;

