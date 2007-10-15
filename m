From: Guillaume Chazarain <guichaz@yahoo.fr>
Subject: Re: [NET]: Fix csum_start update in pskb_expand_head
Date: Mon, 15 Oct 2007 11:21:29 +0200
Message-ID: <20071015112129.2bd7ef16@inria.fr>
References: <20071006141506.785a6683@localhost.localdomain>
	<20071014192640.35065e73@inria.fr>
	<20071014222037.7fa28640@inria.fr>
	<20071015045723.GA28388@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g19.free.fr ([212.27.42.29]:39359 "EHLO smtp3-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757163AbXJOJYQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 05:24:16 -0400
In-Reply-To: <20071015045723.GA28388@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le Mon, 15 Oct 2007 12:57:23 +0800,
Herbert Xu <herbert@gondor.apana.org.au> a =C3=A9crit :

> [NET]: Fix csum_start update in pskb_expand_head
> [NET]: Avoid copying TCP packets unnecessarily

I am Bittorrenting for a few hours with these patches, and they seem to
work well. Thanks for the quick response.

> ethtool -k <IFNAME>

eth1 is an ipw2200
[root ~]# ethtool -k eth1
Offload parameters for eth1:
Cannot get device rx csum settings: Operation not supported
rx-checksumming: off
tx-checksumming: off
scatter-gather: off
tcp segmentation offload: off
udp fragmentation offload: off
generic segmentation offload: off

Just in case you get a new interest ;-)

Thanks.

--=20
Guillaume
