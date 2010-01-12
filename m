From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH 2/3] Security: Implement disablenetwork semantics. (v4)
Date: Mon, 11 Jan 2010 22:19:48 -0500
Message-ID: <6161.1263266388@localhost>
References: <20100110215848.GA26609@elf.ucw.cz> <20100110224010.GA3825@heat> <201001111007.EAG82373.VHFQSLFOFMOOJt@I-love.SAKURA.ne.jp>
            <4B4A8309.9090801@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1263266388_4979P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	michael@laptop.org, pavel@ucw.cz, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	andi@firstfloor.org, david@lang.hm, socketcan@hartkopp.net,
	alan@lxorguk.ukuu.org.uk, herbert@gondor.apana.org.au,
	bdonlan@gmail.com, zbr@ioremap.net, cscott@cscott.net,
	jmorris@namei.org, ebiederm@xmission.com, bernie@codewiz.org,
	mrs@mythic-beasts.com, randy.dunlap@oracle.com,
	xiyou.wangcong@gmail.com, sam@synack.fr, serue@us.ibm.com,
	viro@ZenIV.linux.org.uk
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: Your message of "Sun, 10 Jan 2010 17:46:49 PST."
             <4B4A8309.9090801@schaufler-ca.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1263266388_4979P
Content-Type: text/plain; charset=us-ascii

On Sun, 10 Jan 2010 17:46:49 PST, Casey Schaufler said:
> It's much worse than that. A user that has been network disabled
> who tries using ls may find that it goes looking for the network
> on each name lookup and has to wait for a timeout for each.

Ya know Casey - I learned back in 1986 or so that if you set up a SunOS 3.2
cluster using Yellow Pages, professors who managed to unplug the AUI cable
on the back of their Sun 3/50 would notice things blowing chunks.  I have to
admit that 24 years ago I told them "Well don't do that then", and I have
to say the same thing for anybody running a login shell network-disabled.

Now, a more subtle point is that a *program* may call getuserbyname() or
getuserbyuid() and be surprised when it times out - but that's a
different issue than a network-deprived user calling /bin/ls.

>          Then, if there are local file entries that differ
> from the "official" network account values when the library
> functions finally fall back on the local values you get the wrong
> names for file owners.

The sysadmin who set that up already had the bullet in the chamber and
the gun pointed at their feet.  This is another "we knew better a quarter
century ago" issue - SunOS allowed '+:' at the end of /etc/passwd to merge
in the YP database, and Sun actively discouraged the sort of "local userid
overlaps the YP userid space" misconfiguration you mention.



--==_Exmh_1263266388_4979P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFLS+pUcC3lWbTT17ARAnO9AJ9zSKlp9hpWTOsBYeu2niKQ8xWAkQCgncR0
Hl+wVA8OgqeZUd04P2KiCK4=
=dbY3
-----END PGP SIGNATURE-----

--==_Exmh_1263266388_4979P--

