From: Alan <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 0/4] atl1: Revised Attansic L1 ethernet driver
Date: Mon, 20 Nov 2006 09:46:03 +0000
Message-ID: <20061120094603.1d1e528a@localhost.localdomain>
References: <20061119202817.GA29736@osprey.hogchain.net>
	<20061120011534.54b1e010@localhost.localdomain>
	<45614C80.5070303@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jay Cliburn <jacliburn@bellsouth.net>, jeff@garzik.org,
	shemminger@osdl.org, romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:18315 "EHLO
	lxorguk.ukuu.org.uk") by vger.kernel.org with ESMTP id S934038AbWKTJmI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Nov 2006 04:42:08 -0500
To: Chris Snook <csnook@redhat.com>
In-Reply-To: <45614C80.5070303@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Be careful with :1 bitfields when working with hardware - the compiler
> > has more than one choice about how to pack them.
> 
> Lacking a spec, I'm not entirely sure what the original intent was, so 
> we're stuck with testing.  Is there a specific disambiguation technique 
> you recommend?

Assuming the driver works on x86 then you know how the bits are laid out.
You may find later you need to put in ifdefs for bitfield endian-ness as
we do in things like include/linux/ip.h

