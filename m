From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [patch 4/6] 2.6.18: sb1250-mac: The actual driver update
Date: Wed, 4 Oct 2006 02:10:46 +0100
Message-ID: <20061004011046.GA10247@linux-mips.org>
References: <Pine.LNX.4.64N.0610031549270.4642@blysk.ds.pg.gda.pl> <20061003164253.62f9d5a3.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Maciej W. Rozycki" <macro@linux-mips.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from p549F5BCD.dip.t-dialin.net ([84.159.91.205]:9407 "EHLO
	p549F5BCD.dip.t-dialin.net") by vger.kernel.org with ESMTP
	id S1030542AbWJDBLH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 21:11:07 -0400
Received: from localhost ([127.0.0.1]:37059 "EHLO dl5rb.ham-radio-op.net")
	by lappi.linux-mips.net with ESMTP id S1100414AbWJDBLD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2006 03:11:03 +0200
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061003164253.62f9d5a3.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 03, 2006 at 04:42:53PM -0700, Andrew Morton wrote:

> On Tue, 3 Oct 2006 16:18:44 +0100 (BST)
> "Maciej W. Rozycki" <macro@linux-mips.org> wrote:
> 
> > +	sbmac_state_t		sbm_state;	/* current state */
> 
> argh.
> 
> The reader looks at this and doesn't know if it's an integer, a void*, a
> struct usb_ac_header_descriptor** or what.
> 
> 	enum sbmac_state	smb_state;
> 
> is nicer.  It has information.

De-typedef-ing would be a separate project for this driver which makes
quite generous use of typedefs.

  Ralf
