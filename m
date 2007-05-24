From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [NET] meth driver renovation
Date: Thu, 24 May 2007 12:51:28 +0100
Message-ID: <20070524115127.GB27073@linux-mips.org>
References: <8A9D56C5E50F774BABE033F1710B3576093B15@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org
To: Shane McDonald <Shane_McDonald@pmc-sierra.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:33808 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755999AbXEXLvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 07:51:46 -0400
Received: from localhost.localdomain ([127.0.0.1]:42446 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20021943AbXEXLvo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2007 12:51:44 +0100
Content-Disposition: inline
In-Reply-To: <8A9D56C5E50F774BABE033F1710B3576093B15@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 23, 2007 at 01:02:18PM -0700, Shane McDonald wrote:

> >  static void __exit meth_exit_module(void)
> >  {
> > -	unregister_netdev(meth_dev);
> > -	free_netdev(meth_dev);
> > +	platform_driver_register(&meth_driver);
> >  }
> 
>                       ^^^^^^^^
> 
>       platform_driver_unregister(&meth_driver);

Indeed.  Will send new patch in separate email.

  Ralf
