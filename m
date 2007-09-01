From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: 2.6.23-rc4-mm1 "no CRC" MODPOST warnings
Date: Sun, 2 Sep 2007 01:15:54 +0200
Message-ID: <20070901231554.GA7318@uranus.ravnborg.org>
References: <20070831215822.26e1432b.akpm@linux-foundation.org> <alpine.LFD.0.999.0709020327260.20781@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:58213 "EHLO pasmtpA.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757151AbXIAXOe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Sep 2007 19:14:34 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0709020327260.20781@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 02, 2007 at 03:36:08AM +0530, Satyam Sharma wrote:
> 
> 
> On Fri, 31 Aug 2007, Andrew Morton wrote:
> > 
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc4/2.6.23-rc4-mm1/
> 
> Got these on an i386 build with CONFIG_MODVERSIONS=y ...
> 
> WARNING: "div64_64" [net/netfilter/xt_connbytes.ko] has no CRC!
> WARNING: "div64_64" [net/ipv4/tcp_cubic.ko] has no CRC!

As Adrian already commented it is fixed in kbuild.git.
It happes bacause genksyms did not know __extension__ and error recovery
in the parser were bad. I only managed to add support for __extension__ but
the error receovery are not fixed :-(

kbuild.git is not part of this -mm due to me fucking up the above fix.
That is corrected now so it will be in next -mm.

	Sam
