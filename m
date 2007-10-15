From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH][BNX2X] round three
Date: Mon, 15 Oct 2007 18:24:02 +0200
Message-ID: <20071015162402.GB15178@one.firstfloor.org>
References: <1192038559.29746.127.camel@eliezer> <p73641c4cfz.fsf@bingen.suse.de> <20071012.150341.41635825.davem@davemloft.net> <1192462049.29746.158.camel@eliezer> <20071015160512.GA15178@one.firstfloor.org> <1192465323.29746.170.camel@eliezer>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jeff@garzik.org, mchan@broadcom.com
To: Eliezer Tamir <eliezert@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:58896 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757582AbXJOQYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 12:24:05 -0400
Content-Disposition: inline
In-Reply-To: <1192465323.29746.170.camel@eliezer>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 15, 2007 at 06:22:03PM +0200, Eliezer Tamir wrote:
> On Mon, 2007-10-15 at 18:05 +0200, Andi Kleen wrote:
> > > This is not a driver issue.
> > > Unfortunately, the firmware code is different for LE and BE machines.
> > > We had issues with the BE firmware that appear to be resolved.
> > > Hopefully, the next version will have both.
> > 
> > If the firmware is big it might be better to just add the necessary
> > conversions to the driver and always use BE. Endian conversions
> > tend to be very cheap.
> 
> For a given architecture, only the right version of the microcode is
> compiled, so the binary only contains one copy of the microcode.

But we still have source code bloat. drivers/net already has too much
binary gibberish in hex; no need to add to it unnecessarily.

-Andi
