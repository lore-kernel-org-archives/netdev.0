From: Mark Hindley <mark@hindley.org.uk>
Subject: Re: [PATCH -mm 1/2] 3c59x: Fix uninitialized variable bug
Date: Tue, 4 Sep 2007 10:35:10 +0100
Message-ID: <20070904093510.GL5944@hindley.org.uk>
References: <alpine.LFD.0.999.0709040340250.8504@enigma.security.iitk.ac.in> <20070904081602.GB4241@newton.mathematik.tu-chemnitz.de> <20070904085331.GH5944@hindley.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Satyam Sharma <satyam@infradead.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev Mailing List <netdev@vger.kernel.org>,
	Jeff Garzik <jeff@garzik.org>
To: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753386AbXIDJf3@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 04, 2007 at 11:17:57AM +0200, Steffen Klassert wrote:
 
> The only warning that I was able to trigger with gcc 4.2 is in the case of a .config
> without PCI support. In this case I get
> 
> drivers/net/3c59x.c: In function 'vortex_up':
> drivers/net/3c59x.c:1672: warning: 'err' is used uninitialized in this function

That should be fixed by Satyam's patch too.

Mark
