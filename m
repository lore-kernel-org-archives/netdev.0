From: Valdis.Kletnieks@vt.edu
Subject: Re: mmotm 2010-03-23 - IPv6 warnings...
Date: Thu, 25 Mar 2010 12:45:30 -0400
Message-ID: <4788.1269535530@localhost>
References: <201003232301.o2NN1bms031050@imap1.linux-foundation.org> <12096.1269481001@localhost>
            <20100324184226.3bf42d8f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1269535530_3923P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: Your message of "Wed, 24 Mar 2010 18:42:26 EDT."
             <20100324184226.3bf42d8f.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1269535530_3923P
Content-Type: text/plain; charset=us-ascii

On Wed, 24 Mar 2010 18:42:26 EDT, Andrew Morton said:
> On Wed, 24 Mar 2010 21:36:41 -0400 Valdis.Kletnieks@vt.edu wrote:
> 
> > On Tue, 23 Mar 2010 15:34:59 PDT, akpm@linux-foundation.org said:
> > > The mm-of-the-moment snapshot 2010-03-23-15-34 has been uploaded to
> > > 
> > >    http://userweb.kernel.org/~akpm/mmotm/
> > 
> > Seen in my dmesg.  It may be relevant that I'm at home, and my IPv6
> > prefix arrives via a PPP VPN connection. This happened about 20-25 seconds
> > after I launched pppd.
> 
> Yes, thanks, I get the same - it doesn't seem to break anything.  It
> also happens some time after boot has completed.

Just doing an 'ifup eth0' on a network with IPv6 on it is sufficient.

And it does break stuff:

% ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 00:24:E8:C6:AD:17  
          inet addr:128.173.14.107  Bcast:128.173.15.255  Mask:255.255.252.0
          inet6 addr: fe80::224:e8ff:fec6:ad17/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1

With 2.6.34-rc1-mmotm0309, I see:

% ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 00:24:E8:C6:AD:17  
          inet addr:128.173.14.107  Bcast:128.173.15.255  Mask:255.255.252.0
          inet6 addr: 2001:468:c80:2103:224:e8ff:fec6:ad17/64 Scope:Global
          inet6 addr: fe80::224:e8ff:fec6:ad17/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1

Something ate my IPv6 address.  We run a lot of IPv6 in production, so stuff
is acting wonky.



--==_Exmh_1269535530_3923P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFLq5MqcC3lWbTT17ARAtBFAJ9A4+be940OdkBcHV2GMPkZcbvcsQCfVHkf
hRF8cPitJhxdSO45oNVnnnA=
=xB9H
-----END PGP SIGNATURE-----

--==_Exmh_1269535530_3923P--
