From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH 17/11]Optimize the upload speed for PPP connection.
Date: Tue, 17 Nov 2009 13:49:47 -0500
Message-ID: <13129.1258483787@turing-police.cc.vt.edu>
References: <faf197be196ee.196eefaf197be@huawei.com> <20091117.012248.86306050.davem@davemloft.net>
            <4B0278D9.6030806@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1258483787_3145P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: huananhu@huawei.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754628AbZKQSt7@vger.kernel.org>
In-Reply-To: Your message of "Tue, 17 Nov 2009 05:20:09 EST."
             <4B0278D9.6030806@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1258483787_3145P
Content-Type: text/plain; charset=us-ascii

On Tue, 17 Nov 2009 05:20:09 EST, William Allen Simpson said:

> And your trailer boilerplate badly breaks the system, because it's
> missing the SMTP email standard "--" line in front of it.

Ahem.

It's not an 'SMTP standard' - in fact, SMTP doesn't even care diddly about the
user-visible *headers* in the mail, much less what the convention for a
signature block is.  If you get EHLO, MAIL FROM, RCPT TO, DATA, '.', and QUIT,
that's 95% of SMTP right there.  And none of it where normal users can even see
it (though the MAIL FROM can show up as Return-Path: sometimes).

The '-- ' *convention* isn't even at the next layer up, MIME.  If anything,
it's out at the liveware level (though some MUAs provide code to make it
a bit easier to deal with...)

(Feel free to cite RFC chapter-and-verse if you disagree, and note that
'Informational' RFCs are never standards. ;)


--==_Exmh_1258483787_3145P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFLAvBLcC3lWbTT17ARAh4gAJ0UgrRzYglUYi7BUvV0tJBgMqvInQCg96oH
aHc4tK9YfM0wvn2Qct92I8k=
=yer/
-----END PGP SIGNATURE-----

--==_Exmh_1258483787_3145P--
