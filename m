From: Milan Kocian <milon@wq.cz>
Subject: Re: Could you make vconfig less stupid?
Date: Tue, 7 Oct 2008 15:28:02 +0200
Message-ID: <20081007132800.GH4606@ntm.vs.lam.cz>
References: <20081006202401.14f03be2@speedy> <200810071520.56610.denys@visp.net.lb> <20081007124820.GG4606@ntm.vs.lam.cz> <200810071549.16647.denys@visp.net.lb> <48EB5C63.60501@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="y9PDtDHaFrXNoMPU"
Cc: Denys Fedoryshchenko <denys@visp.net.lb>,
	Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srw1.wq.cz ([212.71.155.176]:37658 "EHLO srw1.wq.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751133AbYJGN2J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2008 09:28:09 -0400
Content-Disposition: inline
In-Reply-To: <48EB5C63.60501@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--y9PDtDHaFrXNoMPU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 07, 2008 at 02:56:03PM +0200, Patrick McHardy wrote:
> Denys Fedoryshchenko wrote:
>> On Tuesday 07 October 2008, Milan Kocian wrote:
>>> hello,
>>>
>>> btw. How can I see vlan id on device ?
>>> After:
>>> # ip l a l eth0 type vlan id 100
>>> # ip a
>>> I see:
>>>
>>> 64: vlan0@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
>>>     link/ether 00:16:d3:3e:4e:b9 brd ff:ff:ff:ff:ff:ff
>>>
>>> No vlan id in interface name ?
>>>
>>> # ip -V
>>> ip utility, iproute2-ss080725
>>>
>>> regards,
>> Use flag -d
>> rich ip # ./ip -d l show dev vlan0
>> 31: vlan0@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
>>     link/ether 00:1e:8c:89:78:af brd ff:ff:ff:ff:ff:ff
>>     vlan id 100 <REORDER_HDR>
>
> It would be better to have -d as a default, I was afraid of breaking
> scripts of people sedding and awking around with the iproute output.
>
> Stephen should make this call, I'm not sure what guarantees he wants
> to provide. I just remembered one of my previous jobs where a large
> number of scripts had to be changed because iproute started using
> lower case letters in some spots, and I had to do it :)

Thanks for quick answer.=20
Yes, -d will be fine.
It is a pity that vlan id will not be in interface name. It was=20
comfortable to have vlan id in interface name.=20
Any reason for changing naming schema ?

regards,

--=20
Milan Kocian

--y9PDtDHaFrXNoMPU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkjrY+AACgkQPxnHOr4hZ+rmgACfS7K3B59L24exSSSYb11F6m++
dMMAn26h/XhuYI4k2589M41eLmAI+sV/
=vqRT
-----END PGP SIGNATURE-----

--y9PDtDHaFrXNoMPU--
