From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 1/3] [NET]: Supporting UDP-Lite (RFC 3828) in Linux
Date: Mon, 13 Nov 2006 07:34:48 +0000
Message-ID: <200611130734.49700@strip-the-willow>
References: <200611101609.21333@strip-the-willow> <20061110.143801.39158000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:16035 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S1754207AbWKMHfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Nov 2006 02:35:07 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061110.143801.39158000.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting David Miller:
|  
|  I can't apply any of this Gerrit.
|  
|  What makes net/ipv4/udplite.c get built at all?  I see no
|  changes to net/ipv4/Makefile, so you must have stuffed up
|  the generation of your patches.
This is a misunderstanding: udplite.o will never be built, 
it is #included in udp.c. Witness

==> net/ipv4/udp.c, line 1727:
	
	/* the extensions for UDP-Lite (RFC 3828) */
	#include "udplite.c"

==> net/ipv6/udp.c, line 1009:
	/* the extensions for UDP-Lite (RFC 3828) */
	#include "udplite.c"


|  Please resubmit all 3 patches once you've corrected this
|  and actually _tested_ the patch you submitted.  You know,
I do not submit patches that I don't have tested myself. It
all works: no compile errors, all functions (UDPv4/v6 and 
UDP-Litev4/v6) confirmed to work.

You can find test applications for UDP-Lite (IPPROTO=136) on 

http://www.erg.abdn.ac.uk/users/gerrit/udp-lite/files/udplite_linux.tar.gz

(subdirectory apps/{sock,ttcp,vlc,client-server,perl_client-server}

Regards
Gerrit
