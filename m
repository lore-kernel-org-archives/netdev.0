From: "David S. Miller" <davem@redhat.com>
Subject: Re: off by one error in 3des cbc keying
Date: Tue, 12 Nov 2002 14:36:36 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021112.143636.55033627.davem@redhat.com>
References: <20021111200321.GA30957@outpost.ds9a.nl>
	<200211121355.QAA00322@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ahu@ds9a.nl, gem@asplinux.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200211121355.QAA00322@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: kuznet@ms2.inr.ac.ru
   Date: Tue, 12 Nov 2002 16:55:57 +0300 (MSK)

   Comments for Dave:
   
   1. udp.c: silly bug, local input policy did not work on udp sockets.
   2. ah.c,esp.c: even sillier bug: 0 was used as  tunnels protocol. Funny enough,
      it worked between linuxes. :-) By <gem@asplinux.ru>
   
Applied, thanks.
   
   Another fix for wrongly formatted ICV for ESP will follow
   tonight after test for interoperability with freebsd.
   
   The problem with expiration remains unsolved. I still cannot reproduce this
   and cannot find a situation when kernel can create two larvals with one
   identity. :-( Searching.
   
Ok, I continue with xfrm_user.  Damn I must finish this crap :)
