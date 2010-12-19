From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] bnx2x: Add Nic partitioning mode (57712
 devices)
Date: Sun, 19 Dec 2010 21:21:52 +0000
Message-ID: <1292793712.2874.13.camel@localhost>
References: <1290982177.6066.3.camel@lb-tlvb-dmitry>
	 <20101129060114.GC29904@auslistsprd01.us.dell.com>
	 <1291023192.9770.0.camel@lb-tlvb-eilong.il.broadcom.com>
	 <20101206173534.GC13628@auslistsprd01.us.dell.com>
	 <4CFD29BE.2060201@chelsio.com>
	 <1291906166.21210.10.camel@lb-tlvb-eilong.il.broadcom.com>
	 <20101217024509.GA5854@auslistsprd01.us.dell.com>
	 <1292592157.3136.819.camel@localhost>
	 <20101219055731.GD5854@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eilon Greenstein <eilong@broadcom.com>,
	Dimitris Michailidis <dm@chelsio.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"narendra_k@dell.com" <narendra_k@dell.com>,
	"jordan_hargrave@dell.com" <jordan_hargrave@dell.com>
To: Matt Domsch <Matt_Domsch@dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:40354 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756728Ab0LSVV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Dec 2010 16:21:58 -0500
In-Reply-To: <20101219055731.GD5854@auslistsprd01.us.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-12-18 at 23:57 -0600, Matt Domsch wrote:
> On Fri, Dec 17, 2010 at 01:22:37PM +0000, Ben Hutchings wrote:
> > On Thu, 2010-12-16 at 20:45 -0600, Matt Domsch wrote:
> > > On Thu, Dec 09, 2010 at 04:49:25PM +0200, Eilon Greenstein wrote:
> > In the case of sfc, each port has a separate PCI function.  We read this
> > register field to find out which port we're talking to, as
> > virtualisation can alter the function number.  I don't know about the
> > others.
> 
> For a single card then, this makes sense.
> 
> pci<slot>#<port>  where port = dev_id
> 
> If I have 2 such cards on a PCI extender though, I think this breaks.
> Here, I'd see duplicate dev_id values, yes?
> 
> Do you label the ports on your cards in any fashion?  Do they have
> labels like port 0, port 1, port 2, ... ?  Does it matter if we give
> names starting at 0, or starting at 1?  latest biosdevname starts them
> at 1, or uses whatever value BIOS actually provides, which on systems
> I've tried, all start at 1.
[...]

Currently they aren't labelled, so far as I can aware.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

