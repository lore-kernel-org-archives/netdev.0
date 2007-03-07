From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH 1/2] pcnet32: only allocate init_block dma consistent
Date: Wed, 7 Mar 2007 04:21:55 +0000
Message-ID: <20070307042155.GA6495@linux-mips.org>
References: <20070306184523.GA23268@verizon.net> <20070307031011.GA4281@linux-mips.org> <f2b55d220703061939w731dfcc4t8e0ddcf238203bd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Don Fry <pcnet32@verizon.net>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: "Michael K. Edwards" <medwards.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:56782 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932471AbXCGEXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 23:23:52 -0500
Received: from localhost.localdomain ([127.0.0.1]:56274 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20021495AbXCGEXu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2007 04:23:50 +0000
Content-Disposition: inline
In-Reply-To: <f2b55d220703061939w731dfcc4t8e0ddcf238203bd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 06, 2007 at 07:39:21PM -0800, Michael K. Edwards wrote:

> On 3/6/07, Ralf Baechle <ralf@linux-mips.org> wrote:
> >This small change btw. delivers about ~ 3% extra performance on a very
> >slow test system.
> 
> Has this change been tested / benchmarked under VMWare?  pcnet32 is
> the (default?) virtual device presented by VMWare Workstation, and
> that's probably a large fraction of its use in the field these days.
> But then Don probably already knows that.  :-)

Price question: why would this patch make a difference under VMware? :-)

  Ralf
