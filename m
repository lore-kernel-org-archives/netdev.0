From: Andreas Unterluggauer <au@unterluggauer.org>
Subject: Re: Fw: [Bugme-new] [Bug 4138] New: ipsec with racoon in transport mode with esp and ah hangs (problem is in xfrm_state_add)
Date: Tue, 1 Feb 2005 11:53:02 +0100
Message-ID: <200502011153.03284.au@unterluggauer.org>
References: <E1CvZCT-00017g-00@gondolin.me.apana.org.au> <200501311640.16118.au@unterluggauer.org> <20050131211102.GA20323@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050131211102.GA20323@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hallo Herbert,

> On Mon, Jan 31, 2005 at 03:40:16PM +0000, Andreas Unterluggauer wrote:
> > 2005-01-31 16:29:58: DEBUG: ===
> > 2005-01-31 16:29:58: DEBUG: get pfkey ADD message
> > andi: libipsec/pfkey.c, pfkey_check: start (msg->sadb_msg_satype: 3)
> > 2005-01-31 16:29:58: DEBUG: andi: in pfkey.c, pk_recvadd:
> > msg->sadb_msg_seq 2, msg->sadb_msg_type: ADD 2005-01-31 16:29:58: INFO:
> > IPsec-SA established: ESP/Transport 192.168.2.5->192.168.2.3
> > spi=103868257(0x630e761) 2005-01-31 16:29:58: DEBUG: ===
>
> Does the machine hang at this point in time? If not, then this is
> simply a racoon bug.  Although the acquire message carries a policy
> with it, it's really only acquiring a single SA.  Therefore, only
> the SA being acquired should be added with that sequence number.
the machine (kernel) is not hanging!
only the programm (e.g. ping ) is hanging until it gets a timeout. the kernel 
is acquiring a SA and racoon answers, and the kernel is acquiring and racoon 
answers ... until the user-programm stops.

thanks for the information, that its a racoon (ipsec-tools) problem.  I will 
contact the ipsec-tools developers.

ciao
andi
