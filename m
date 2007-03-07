From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: [PATCH 1/2] pcnet32: only allocate init_block dma consistent
Date: Wed, 7 Mar 2007 09:50:08 -0500
Message-ID: <20070307145008.GB22467@csclub.uwaterloo.ca>
References: <20070306184523.GA23268@verizon.net> <20070307031011.GA4281@linux-mips.org> <f2b55d220703061939w731dfcc4t8e0ddcf238203bd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>, Don Fry <pcnet32@verizon.net>,
	jgarzik@pobox.com, netdev@vger.kernel.org
To: "Michael K. Edwards" <medwards.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:55837 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1422722AbXCGOuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 09:50:10 -0500
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

Unless you install vmware tools in which case you use vmxnet instead
which of course performs better since it knows it isn't talking to real
hardware.

I am currently about to try what this patch does to the performance of
our system (266MHz Geode SC1200 with 4 pcnet32's).

--
Len Sorensen
