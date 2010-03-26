From: Valdis.Kletnieks@vt.edu
Subject: Re: mmotm 2010-03-23 - IPv6 warnings...
Date: Fri, 26 Mar 2010 02:18:22 -0400
Message-ID: <4161.1269584302@localhost>
References: <12096.1269481001@localhost> <20100324184226.3bf42d8f.akpm@linux-foundation.org> <4788.1269535530@localhost>
            <20100325.214050.101816448.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1269584302_4034P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: Your message of "Thu, 25 Mar 2010 21:40:50 PDT."
             <20100325.214050.101816448.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1269584302_4034P
Content-Type: text/plain; charset=us-ascii

On Thu, 25 Mar 2010 21:40:50 PDT, David Miller said:
> From: Valdis.Kletnieks@vt.edu
> Date: Thu, 25 Mar 2010 12:45:30 -0400
> 
> > On Wed, 24 Mar 2010 18:42:26 EDT, Andrew Morton said:
> >> On Wed, 24 Mar 2010 21:36:41 -0400 Valdis.Kletnieks@vt.edu wrote:
> >> 
> >> > On Tue, 23 Mar 2010 15:34:59 PDT, akpm@linux-foundation.org said:
> >> > > The mm-of-the-moment snapshot 2010-03-23-15-34 has been uploaded to
> >> > > 
> >> > >    http://userweb.kernel.org/~akpm/mmotm/
> >> > 
> >> > Seen in my dmesg.  It may be relevant that I'm at home, and my IPv6
> >> > prefix arrives via a PPP VPN connection. This happened about 20-25 secon
ds
> >> > after I launched pppd.
> >> 
> >> Yes, thanks, I get the same - it doesn't seem to break anything.  It
> >> also happens some time after boot has completed.
> > 
> > Just doing an 'ifup eth0' on a network with IPv6 on it is sufficient.
> 
> I just checked the following into net-next-2.6 which should at least
> kill that dmesg log.
> 
> If you still are missing your ipv6 addresses, let me know how
> they normally get added, maybe that's enough to let me figure
> it out.

Confirming looks like a good fix - no cruft in dmesg, and I have ipv6 addresses:

%  ifconfig ppp0
ppp0      Link encap:Point-to-Point Protocol  
          inet addr:128.173.34.103  P-t-P:128.173.32.21  Mask:255.255.255.255
          inet6 addr: 2001:468:c80:3b04:105d:a65c:28c4:75d1/64 Scope:Global
          inet6 addr: fe80::105d:a65c:28c4:75d1/10 Scope:Link
          UP POINTOPOINT RUNNING NOARP MULTICAST  MTU:1460  Metric:1
          RX packets:79 errors:0 dropped:0 overruns:0 frame:0
          TX packets:85 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:3 
          RX bytes:30943 (30.2 KiB)  TX bytes:6746 (6.5 KiB)

--==_Exmh_1269584302_4034P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFLrFGucC3lWbTT17ARAg2mAKCcelwxtW8pgkKsfI6PI+lOBMGcewCg197d
FV2sB6YypJHhMfiXB5/DQpg=
=J1Bp
-----END PGP SIGNATURE-----

--==_Exmh_1269584302_4034P--
