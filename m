From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of
 IRQF_SAMPLE_RANDOM
Date: Fri, 16 May 2008 21:46:12 +0100
Message-ID: <20080516214612.127412a7@core>
References: <482C7E53.3050300@hp.com>
	<482C8184.2030906@garzik.org>
	<482C8550.5000909@intel.com>
	<482C8D4D.3040702@garzik.org>
	<20080516132107.GA11304@csclub.uwaterloo.ca>
	<20080516161029.44ded734@core>
	<20080516173610.GA27126@csclub.uwaterloo.ca>
	<20080516191125.46f59ad6@core>
	<20080516184138.GF27126@csclub.uwaterloo.ca>
	<20080516210445.6f961627@core>
	<20080516203932.GH27126@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Rick Jones <rick.jones2@hp.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Chris Peterson <cpeterso@cpeterso.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:39400 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754173AbYEPU5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 16:57:45 -0400
In-Reply-To: <20080516203932.GH27126@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 May 2008 16:39:33 -0400
lsorense@csclub.uwaterloo.ca (Lennart Sorensen) wrote:

> On Fri, May 16, 2008 at 09:04:45PM +0100, Alan Cox wrote:
> > So open /dev/urandom in that case. It's a user space problem - this is
> > policy.
> 
> How does user space know?  Maybe someone is using the serial console,
> maybe not.

How does the kernel know - it has even less useful policy information ?
