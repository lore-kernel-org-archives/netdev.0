From: Marc Zyngier <mzyngier@freesurf.fr>
Subject: Re: [PATCH][2.6] de4x5 cleanup
Date: Sat, 30 Aug 2003 23:22:02 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <wrphe3y6dtx.fsf@hina.wild-wind.fr.eu.org>
References: <wrpad9r79g6.fsf@hina.wild-wind.fr.eu.org>
	<3F50E3FD.1000703@pobox.com>
	<wrpn0dr55n1.fsf@hina.wild-wind.fr.eu.org>
	<3F50F805.9090805@pobox.com>
Reply-To: mzyngier@freesurf.fr
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, linux-net@vger.kernel.org,
   Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F50F805.9090805@pobox.com> (Jeff Garzik's message of "Sat, 30
 Aug 2003 15:16:21 -0400")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>>> "Jeff" == Jeff Garzik <jgarzik@pobox.com> writes:

Jeff> Well, 2.6 tulip intentionally doesn't work at all on 21040 and
Jeff> 21041 :) That's what de2104x driver is for.  Can you give that a
Jeff> beating, and verify that it works for you?

Last time I checked, I had ugly Oopses on one of my alpha boxes
(AS-255), but that whas a few month ago, and I had other stuff to fix
at the moment. I'll give it a go tomorrow.

Jeff> If it meant I could kill de4x5, then I would be all for adding
Jeff> EISA support to tulip... :)

I'm afraid this would introduce a lot of the ugly crap that is
currently in de4x5 (21040 is seen through an EISA to PCI bridge, with
a sparse mapping)... I'll have a look at what we can do without
introduce too many hacks.

If de2104x behaves correctly, another solution would be to turn de4x5
to be EISA only. That would be a good way to finally kill it ;-).

Thanks,

        M.
-- 
Places change, faces change. Life is so very strange.
