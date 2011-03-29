From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: SAE J1939: update
Date: Tue, 29 Mar 2011 21:41:22 +0200
Message-ID: <4D9235E2.2030807@hartkopp.net>
References: <20110314132004.GA333@e-circ.dyndns.org> <20110314135917.GF333@e-circ.dyndns.org> <4D8623BE.2080807@hartkopp.net> <20110329142907.GB335@kurt.e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: socketcan-core@lists.berlios.de, netdev@vger.kernel.org
To: Kurt Van Dijck <kurt.van.dijck@eia.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:56838 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751836Ab1C2Tl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2011 15:41:27 -0400
In-Reply-To: <20110329142907.GB335@kurt.e-circ.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29.03.2011 16:29, Kurt Van Dijck wrote:
> Oliver,
> 
> Some progress:
> 
> I dropped the state-machine for the address claiming. This makes it less
> confusing I hope.

Thanks.

> I dropped SO_J1939_DEST_MASK. This could be done in userspace by
> accessing a procfs file, or additional rtnetlink ...
> Lookup up remote ecu's is not strictly necessary in kernel.
> I have no idea yet how such library would look like.

I'll check that with my colleague Urs, who knows very good, which concepts and
'mechanics' are commonly used for such kind of requirements.

> Can userspace tools be attached to the socketCAN subversion can-utils, or
> would a seperate dir be necessary?

I assume about 3-4 tools (like an AC-daemon, some dump or sniffer tool and a
library with some header file) to emerge in can-utils then, which should be
ok. There could also be some test-programms or src-samples that could be
placed in trunk/test .

> I'd say 'suggestions are welcome' but I know you'd suggest to remove
> address claiming..

I'm really very interested in having the address claiming - just somewhere in
userspace :-)

But of course it might become an ambitious target to support the address
claiming with an appropriate infrastructure to help users to fulfill their
needs without getting confused.

Thanks & best regards,
Oliver
