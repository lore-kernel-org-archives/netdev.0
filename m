From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: [PATCH v2 6/6] ipv6: Do route updating for redirect in ndisc
 layer
Date: Wed, 09 Oct 2013 15:00:26 +0800
Message-ID: <5254FF0A.7050805@cn.fujitsu.com>
References: <52327F00.4040802@cn.fujitsu.com> <5232806B.6050601@cn.fujitsu.com> <20130917.202936.2080212548361553334.davem@davemloft.net> <20130918013903.GC8947@order.stressinduktion.org> <5239076A.4080406@cn.fujitsu.com> <20130918041337.GD8947@order.stressinduktion.org> <20131009014324.GA24368@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:41259 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752235Ab3JIHBy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 03:01:54 -0400
In-Reply-To: <20131009014324.GA24368@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B410=E6=9C=8809=E6=97=A5 09:43, Hannes Frederic So=
wa =E5=86=99=E9=81=93:
> Hi Duan!
>=20
> On Wed, Sep 18, 2013 at 06:13:37AM +0200, Hannes Frederic Sowa wrote:
>> Especially because redirects also help in the on-link determination =
(same
>> RFC, section 8), I changed my mind and am still in favour of updatin=
g it
>> in the ndisc layer. In my opinion we just have to consider all routi=
ng
>> tables and apply the update to every one which carries a valid next =
hop
>> to the source of the redirect (under consideration of the destinatio=
n).
>>
>> This will be important if we actually try to get linux to correctly
>> implement the ipv6 subnet model (RFC 5942, Section 4 Rule 1). In tha=
t
>> case we are not allowed to assume nodes on-link even if they would m=
atch
>> the same prefix as a locally configured address.
>=20
> I am playing around with a simple patch which does suppress adding ro=
uting
> information for the on-link assumption we currently do in linux.
>=20
> Are you intereseted in following up on this? I still do think we shou=
ld update
> not only the routing table the socket uses but all routing tables whi=
ch have a
> valid route towards the router which emitted the redirect.
>=20

No, thanks, i have got other things on my mind, more important, but i w=
ill
pay attention to it.

Thanks,
  Duan.

> I try to check if we actually handle redirect messages when ECMP rout=
es are in
> use correctly.
>=20
