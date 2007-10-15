From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: Re: [PATCH][BNX2X] round three
Date: Mon, 15 Oct 2007 17:27:29 +0200
Message-ID: <1192462049.29746.158.camel@eliezer>
References: <1192038559.29746.127.camel@eliezer>
 <p73641c4cfz.fsf@bingen.suse.de>
 <20071012.150341.41635825.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, netdev@vger.kernel.org, jeff@garzik.org,
	mchan@broadcom.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2066 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752464AbXJOP0G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 11:26:06 -0400
In-Reply-To: <20071012.150341.41635825.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-10-12 at 15:03 -0700, David Miller wrote:
> From: Andi Kleen <andi@firstfloor.org>
> Date: Fri, 12 Oct 2007 16:47:28 +0200
> 
> > "Eliezer Tamir" <eliezert@broadcom.com> writes:
> > 
> > 
> > > * For now depend on x86 or x86_64, will add more architectures ASAP.
> > 
> > Why is that? Linux drivers normally should not be architecture specific.
> 
> I totally agree, and the only way to weed out these kinds of
> bugs is to allow it to build on other systems so users can
> try it out and report what fails.  Or even better, a motivated
> developer tries it out and fixes the bugs for you :-)

This is not a driver issue.
Unfortunately, the firmware code is different for LE and BE machines.
We had issues with the BE firmware that appear to be resolved.
Hopefully, the next version will have both.


