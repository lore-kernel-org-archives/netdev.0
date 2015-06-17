From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH v2 0/3] Fix Ethernet jumbo frames support for Armada 370
 and 38x
Date: Wed, 17 Jun 2015 22:43:53 +0200
Message-ID: <20150617224353.5ec9ec9d@free-electrons.com>
References: <1434547162-6275-1-git-send-email-simon.guinot@sequanux.org>
	<20150617172458.3e373b8a@free-electrons.com>
	<20150617172217.GY4853@kw.sim.vm.gnt>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Jason Cooper <jason@lakedaemon.net>,
	netdev@vger.kernel.org, Vincent Donnefort <vdonnefort@gmail.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Simon Guinot <simon.guinot@sequanux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:44512 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752998AbbFQUnz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 16:43:55 -0400
In-Reply-To: <20150617172217.GY4853@kw.sim.vm.gnt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simon,

On Wed, 17 Jun 2015 19:22:17 +0200, Simon Guinot wrote:

> > You should add a Fixes: tag to each commit to indicate which commit is
> > being fixed by your patches.
> > 
> > Also, I was a bit surprised by your statement that Armada 38x is also
> > affected by the problem, since Armada 38x is more recent than Armada
> > XP. but indeed, according to the Armada 38x datasheet:
> > 
> >   IPv4 and TCP/UDP over IPv4/IPv6 checksum generation on transmit
> >   frames for standard Ethernet packet size
> > 
> > While the Armada XP datasheet says:
> > 
> >   Long frames transmission (including jumbo frames), with
> >   IPv4/v6/TCP/UDP checksum generation
> > 
> > So it seems like you're right about this!
> 
> At first, I though this was an error in the Armada 38x datasheet (maybe
> a sloppy copy/paster). Therefore I have checked on an DB-88F6820-GP
> board and then I can confirm that the Armada 38x is also affected.

Ok, so the datasheet was correct (houra!). Thanks a lot for having done
the additional testing.

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
