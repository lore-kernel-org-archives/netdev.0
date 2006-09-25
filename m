From: Joerg Roedel <joro-lkml@zlug.org>
Subject: Re: [PATCH 00/03][RESUBMIT] net: EtherIP tunnel driver
Date: Mon, 25 Sep 2006 10:32:49 +0200
Message-ID: <20060925083249.GC23028@zlug.org>
References: <20060923120704.GA32284@zlug.org> <20060923121327.GH30245@lug-owl.de> <1159015118.5301.19.camel@jzny2> <20060923132736.GA345@zlug.org> <200609250107.k8P17h8A019714@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, Jan-Benedict Glaw <jbglaw@lug-owl.de>,
	Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ironport-c10.fh-zwickau.de ([141.32.72.200]:26242 "EHLO
	ironport-c10.fh-zwickau.de") by vger.kernel.org with ESMTP
	id S1750716AbWIYIcv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Sep 2006 04:32:51 -0400
To: Valdis.Kletnieks@vt.edu
Content-Disposition: inline
In-Reply-To: <200609250107.k8P17h8A019714@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 24, 2006 at 09:07:43PM -0400, Valdis.Kletnieks@vt.edu wrote:
> On Sat, 23 Sep 2006 15:27:36 +0200, Joerg Roedel said:
> 
> > (I assume you are speaking of the position of the 3 in the header). The
> > RFC is not clear at this point. It defines that the first 4 bits in the
> > 16 bit Ethernet header MUST be 0011. But it don't defines the
> > byteorder of that 16 bit word nor if the least or most significant bit
> > comes first.
> 
> Unless stated otherwise, it's pretty safe to assume that all "on the wire" data
> mentioned in an RFC is in 'network byte order'.  That's why hton*() and ntoh*()
> functions exist...

Yes. Thats what the OpenBSD people did :-)
The problem with the header is the bitorder. The OpenBSD people assumed
that the least significant bits come first in the 16-bit header.

> Is there something in the RFC that suggests that a byte order other than
> 'network order' is possible/acceptable there?

No. The RFC states nothing at all about byte- or bitorder. That is why
the RFC is ambigious at this point.
