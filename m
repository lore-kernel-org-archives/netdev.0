From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: Re: [PATCH][BNX2X] round three
Date: Mon, 15 Oct 2007 18:22:03 +0200
Message-ID: <1192465323.29746.170.camel@eliezer>
References: <1192038559.29746.127.camel@eliezer>
 <p73641c4cfz.fsf@bingen.suse.de>
 <20071012.150341.41635825.davem@davemloft.net>
 <1192462049.29746.158.camel@eliezer>
 <20071015160512.GA15178@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	jeff@garzik.org, mchan@broadcom.com
To: "Andi Kleen" <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3555 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759262AbXJOQUl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 12:20:41 -0400
In-Reply-To: <20071015160512.GA15178@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-10-15 at 18:05 +0200, Andi Kleen wrote:
> > This is not a driver issue.
> > Unfortunately, the firmware code is different for LE and BE machines.
> > We had issues with the BE firmware that appear to be resolved.
> > Hopefully, the next version will have both.
> 
> If the firmware is big it might be better to just add the necessary
> conversions to the driver and always use BE. Endian conversions
> tend to be very cheap.

For a given architecture, only the right version of the microcode is
compiled, so the binary only contains one copy of the microcode.

The good news is that future versions of the device will not have this
issue.

I can complain all day about hardware designers not listening to the
software guys but then they just might stop talking to me
altogether ;-) 


