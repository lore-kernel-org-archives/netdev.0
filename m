From: Valdis.Kletnieks@vt.edu
Subject: Re: The ultimate TOE design
Date: Fri, 17 Sep 2004 16:27:31 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409172027.i8HKRVwY005444@turing-police.cc.vt.edu>
References: <4148991B.9050200@pobox.com> <OF8783A4F6.D566336C-ON88256F10.006E51CE-88256F10.006EDA93@us.ibm.com>
            <311601c90409162346184649eb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_-239910029P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: David Stevens <dlstevens@us.ibm.com>, Netdev <netdev@oss.sgi.com>,
        leonid.grossman@s2io.com, Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Mudama <edmudama@gmail.com>
In-Reply-To: Your message of "Fri, 17 Sep 2004 00:46:59 MDT."
             <311601c90409162346184649eb@mail.gmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--==_Exmh_-239910029P
Content-Type: text/plain; charset=us-ascii

On Fri, 17 Sep 2004 00:46:59 MDT, Eric Mudama said:
> On Wed, 15 Sep 2004 14:11:04 -0600, David Stevens <dlstevens@us.ibm.com> wrot
e:
> > Why don't we off-load filesystems to disks instead?
> 
> Disks have had file systems on them since close to the beginning...

No, he means "offload the processing of the filesystem to the disk itself".

IBM's MVS  systems basically did that - it used the disk's "Search Key" I/O
opcodes to basically get the equivalent of doing namei() out on the disk itself
(it did this for system catalog and PDS directory searches from the beginning,
and added 'indexed VTOC' support in the mid-80s).  So you'd send out a CCW
(channel command word) stream that basically said "Find me the dataset
USER3.ACCTING.TESTJOBS", and when the I/O completed, you'd have the DSCB (the
moral equiv of an inode) ready to go.


--==_Exmh_-239910029P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFBS0izcC3lWbTT17ARAoKMAJ4pA1BjsPb0sbxLDbLKM9jvox5srACeMV0V
ZMot5U1QnkpacHYr8pIWeJM=
=zjf/
-----END PGP SIGNATURE-----

--==_Exmh_-239910029P--
