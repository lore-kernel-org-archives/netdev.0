From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH ethtool] Fix formatting of RX flow hash indirection table
 when size % 8 != 0
Date: Sun, 19 Apr 2015 13:40:25 +0300
Message-ID: <55338619.4030509@mellanox.com>
References: <1422193883-30504-1-git-send-email-amirv@mellanox.com>
	 <1422193883-30504-5-git-send-email-amirv@mellanox.com>
	 <1428199259.11260.137.camel@decadent.org.uk>
 <1428200099.11260.140.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	"Saeed Mahameed" <saeedm@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0066.outbound.protection.outlook.com ([157.56.112.66]:62000
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751061AbbDSKzI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Apr 2015 06:55:08 -0400
In-Reply-To: <1428200099.11260.140.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA256

On 4/5/2015 5:14 AM, Ben Hutchings wrote:
> We only print a new-line after every 8 entries, but we need one at
> the end of the table even if the table size is not a multiple of
> 8.
> 
> Reported-by: Amir Vadai <amirv@mellanox.com> Signed-off-by: Ben
> Hutchings <ben@decadent.org.uk> --- This is what I've applied -
> hope it works for you as I don't have a test case.
> 
Yes it does :)

Amir

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVM4YZAAoJEAgXBixSko7zCDMP/0xLY9ts5/TDPK8t0ZCHBjik
8OOEasSjjpg8ysLMuBhK4mZETwDZOMZvKGd/ZTFy0UW/xPSDW2PiB1cGrBUIJ+0p
kJ7K+pMeL6RsucRlc+DwRE7mR3/cHPjj33gIJoyW0zzJj9NssP40RAP3aNgL8N0n
6mxNTpoNfncyF7gFL7km1BMxhjAy5cgp/CZ3YdTyxTosNn8udxHQPVVYIgn/UQMQ
+JfIxXB/1i/G4jO0SUENXb+Y/biB98lhItYLHYsVLiDMTMczxb48oF8TA9adQuA9
ke27s9nQTg3oc5ZObL93YBSnr9XRCC94/d3HBAviQmzOKZiFoIkz1vX4RrL8MOXC
xFAwR7F/ozskEUqt8YxRsZpgoyT3zi+MMAHr+c8JtfMWN7ycLpIvQ0/GDuzv7Xjf
lG4VorsSbsdleWpno6aKudzggKjT5ogGifOiAXR4R5CI8DSpvkfMQxHimfm3u3dR
h57mbP18YQnFdEAKnXthdH6s4bUWFKjqjS0Qy0XYy7pLDXowirYz19hvmlgyMwju
NMYQGB+hlUB0pgPgllHGHtWXuI+Dn0OHOscll6DRo2RFeii/1ApQVE0OUxjbbdSL
Nn2yEsqQkb8FiSSGQ83oRZeABscMNgAbXcPZD9ytXiBGwFFKfATbxjc44kIROfZW
y9g7m9glc+CTyUJu8Pok
=1Zqx
-----END PGP SIGNATURE-----
