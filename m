From: Kevin Dwyer <kevin@pheared.net>
Subject: Re: Strange UDP binding behavior (SO_BINDTODEVICE)
Date: Mon, 6 Oct 2003 21:06:00 -0400
Sender: linux-ha-admin@lists.linux-ha.org
Message-ID: <20031006210600.37da62c9.kevin@pheared.net>
References: <20031005130154.5bd9d182.kevin@pheared.net>
	<3F81F1CD.8050803@Carter.net>
Reply-To: linux-ha@lists.linux-ha.org
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="pgp-sha1";
 boundary="Signature=_Mon__6_Oct_2003_21_06_00_-0400_8.KgV4SaTS2UuHQX"
Cc: netdev@oss.sgi.com, linux-ha@lists.linux-ha.org
Return-path: <linux-ha-admin@lists.linux-ha.org>
To: Casey Carter <Casey@Carter.net>
In-Reply-To: <3F81F1CD.8050803@Carter.net>
Errors-To: linux-ha-admin@lists.linux-ha.org
List-Unsubscribe: <http://lists.linux-ha.org/mailman/listinfo/linux-ha>,
	<mailto:linux-ha-request@lists.linux-ha.org?subject=unsubscribe>
List-Post: <mailto:linux-ha@lists.linux-ha.org>
List-Help: <mailto:linux-ha-request@lists.linux-ha.org?subject=help>
List-Subscribe: <http://lists.linux-ha.org/mailman/listinfo/linux-ha>,
	<mailto:linux-ha-request@lists.linux-ha.org?subject=subscribe>
List-Archive: <http://lists.linux-ha.org/pipermail/linux-ha/>
List-Id: netdev.vger.kernel.org

--Signature=_Mon__6_Oct_2003_21_06_00_-0400_8.KgV4SaTS2UuHQX
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

On Mon, 06 Oct 2003 17:50:53 -0500
Casey Carter <Casey@Carter.net> wrote:

> This is not a bug, it's a feature!  It is possible to use multiple 
> sockets with the same port number bound to different interfaces (where
> "no interface" is one possible choice).  The UDP packet delivery code 
> favors the socket that is bound to the interface through which packets
> are received. So, if I am only interested in packets for port 6666 on 
> eth1, then I am prioritized ahead of the socket bound to "no
> interface" port 6666.  

Well, I would buy that as reasonable, acceptable behavior, but I think
the reverse is true.

We are binding specifically to say, eth0 on port 694.  Someone comes
along and binds to "no interface" on port 694 and trumps our socket. 
Isn't that the opposite of what you describe?

-- 
- kpd
"If at first you don't succeed, redefine success." - Anonymous

--Signature=_Mon__6_Oct_2003_21_06_00_-0400_8.KgV4SaTS2UuHQX
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQE/ghF7N4rbBhHCVDkRArTxAJ9R2pv9Z9CReHsjc7ME1Eaf5GvhZQCgkOtA
z18NlcvJg0aSBETQPQ0VxXk=
=RLiO
-----END PGP SIGNATURE-----

--Signature=_Mon__6_Oct_2003_21_06_00_-0400_8.KgV4SaTS2UuHQX--
_______________________________________________
Linux-HA mailing list
Linux-HA@lists.linux-ha.org
http://lists.linux-ha.org/mailman/listinfo/linux-ha
