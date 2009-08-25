From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Tue, 25 Aug 2009 15:48:11 +0200
Message-ID: <4A93EB9B.5020600@gmail.com>
References: <alpine.DEB.1.10.0908171548040.20399@gentwo.org>  <4A89C026.4030402@us.ibm.com>  <alpine.DEB.1.10.0908171642500.20399@gentwo.org>  <1250545839.25939.21.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171813070.15956@gentwo.org>  <1250549034.25939.30.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171848370.15956@gentwo.org> <1250554332.25939.46.camel@w-sridhar.beaverton.ibm.com> <alpine.DEB.1.10.0908241334230.30487@gentwo.org> <4A930DEF.5000008@gmail.com> <alpine.DEB.1.10.0908250945460.5972@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Nivedita Singhvi <niv@us.ibm.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:46228 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772AbZHYNse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 09:48:34 -0400
In-Reply-To: <alpine.DEB.1.10.0908250945460.5972@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> On Tue, 25 Aug 2009, Eric Dumazet wrote:
>=20
>> NET_XMIT_CN strikes again :)
>>
>> Well, if ip_local_out() returns a negative error (say -EPERM for exa=
mple),
>>  your patch disables OUTDISCARDS increments.
>>
>> Maybe a simpler patch like this one ?
>=20
> Yes looks good. Can we get this in soon?
>=20

Please hold on, I would like to fully understand what's happening,
and test the patch :)


