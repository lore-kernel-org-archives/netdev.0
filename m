From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [B.A.T.M.A.N.] [PATCH] Fix ARM BUILD_BUG_ON() errors withbatman-adv
Date: Mon, 02 Dec 2013 13:50:46 +0100
Message-ID: <529C8226.2040000@meshcoding.com>
References: <20131130191553.GA16735@n2100.arm.linux.org.uk> <529A46C4.9090906@meshcoding.com> <20131130230518.GC16735@n2100.arm.linux.org.uk> <529A8276.9060002@meshcoding.com> <529B47AA.8060403@meshcoding.com> <20131201171309.GD16735@n2100.arm.linux.org.uk> <AE90C24D6B3A694183C094C60CF0A2F6026B7451@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: The list for a Better Approach To Mobile Ad-hoc
	 Networking <b.a.t.m.a.n@lists.open-mesh.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:46648 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751087Ab3LBMvh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 07:51:37 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7451@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 02/12/13 11:24, David Laight wrote:
> ...
>> The only solutions are: use the GCC packed attribute, redesign
>> the structures...
> 
> It is probably enough to mark the inner structure containing the
> three byte fields 'packed'. Marking it aligned(1) might also have
> the desired effect. The outer structure should then be ok. But
> would need to use a specially named attribute so it doesn't get
> removed.

This may work with the structures I reported in a previous email, but
it is not a good solution for us because we have other more complex
substructs that cannot be packed that way.

I think we will simply duplicate the members and avoid substructs in
our packets.

- -- 
Antonio Quartulli
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iEYEARECAAYFAlKcgiYACgkQpGgxIkP9cwfeeQCfef0xDfD2TucJBhzoTmDfwA29
Oc4An3Etz3USDC0cf/+R+Gyx8LEtpq16
=XZn5
-----END PGP SIGNATURE-----
