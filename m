From: Michael Richardson <mcr@sandelman.ottawa.on.ca>
Subject: Re: [IPSEC] Too many SADs!
Date: Tue, 22 Mar 2005 13:46:25 -0500
Message-ID: <6298.1111517185@marajade.sandelman.ottawa.on.ca>
References: <200503220052.52756.wolfgang.walter@studentenwerk.mhn.de>  <20050322165928.GC8725@ns.snowman.net>
Cc: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>, netdev@oss.sgi.com
To: Stephen Frost <sfrost@snowman.net>
In-Reply-To: Message from Stephen Frost <sfrost@snowman.net>
   of "Tue, 22 Mar 2005 11:59:28 EST." <20050322165928.GC8725@ns.snowman.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----


>>>>> "Stephen" == Stephen Frost <sfrost@snowman.net> writes:
    Stephen> interfaces to the IPSEC in Linux.  Additionally, the
    Stephen> problem isn't that I've got too many policies which end up
    Stephen> requiring too many SADs- the  problem is that SADs are
    Stephen> being created above and beyond what's actually necessary
    Stephen> for my policies, which is a problem.  I'm not entirely sure

  There is certainly a bug in openswan 2.3.1drX, possibly in 2.3.0,
where more SPD entries get created than necessary.
  This would result in many SAD entries, since the incoming SAs are not
removed until they expire, or the remote end asks for them to be deleted.
 
  As the SAD interface in NETKEY provided by netfilter/pfkey does not
permit any kind of "insert here" option, it is possible that there is
some other bug whereby SAD entries multiply.

- -- 
] Michael Richardson          Xelerance Corporation, Ottawa, ON |  firewalls  [
] mcr @ xelerance.com           Now doing IPsec training, see   |net architect[
] http://www.sandelman.ca/mcr/    www.xelerance.com/training/   |device driver[
] panic("Just another Debian GNU/Linux using, kernel hacking, security guy"); [
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)
Comment: Finger me for keys

iQCVAwUBQkBoAIqHRg3pndX9AQEb3wQA4NNgcrdmwlloOJPJX+Z8xdfXNA42Gm1P
M7wDT2nFlOavn04FVNPdp45EzITyoICYHkRXSxhorb42lW5mWahRckSjbujMLw9W
bFdpeVqUj+gitmwAs5VYZ2C3KAxiws6puKnINWgxiZgOHiIkAUotAX6jRkPHF8E5
loREL0C1ykM=
=aC1v
-----END PGP SIGNATURE-----
