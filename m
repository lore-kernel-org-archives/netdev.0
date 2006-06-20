From: Russell Stuart <russell-tcatm@stuart.id.au>
Subject: Re: [LARTC] Re: [PATCH 0/2] Runtime configuration of HTB's
	HYSTERESIS option
Date: Wed, 21 Jun 2006 09:13:14 +1000
Message-ID: <1150845194.17455.25.camel@ras.pc.brisbane.lube>
References: <1150362059.5578.13.camel@ras.pc.brisbane.lube>
	 <44912D27.4010503@cdi.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@comx.dk>, netdev@vger.kernel.org,
	Jamal Hadi Salim <hadi@cyberus.ca>, lartc@mailman.ds9a.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 58.105.229.78.optusnet.com.au ([58.105.229.78]:34504 "EHLO
	adsl-kenny.stuart.id.au") by vger.kernel.org with ESMTP
	id S932088AbWFTXNs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 19:13:48 -0400
To: Martin Devera <devik@cdi.cz>
In-Reply-To: <44912D27.4010503@cdi.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-06-15 at 11:49 +0200, Martin Devera wrote:
> At time of HTB implementation I needed to reach 100MBit speed on 
> relatively slow box. The hysteresis was a way. On other side I used 
> hand-made TSC based measure tool to compute exact (15%) performance 
> gain. Today I'd measure it using oprofile.
> 
> When rethinking it again I'd suggest to re-measure real performance 
> impact for both flat and deep class hierarchy and consider switching the 
> hysteresis off by default (or even to remove the code if the gain is 
> negligible). If it is the case then it is the cleanest solution IMHO.

I attended LCA 2006 this year.  There was a presentation by
a group in New Zealand using Debian running on a embedded
box to bring the Internet to rural communities.  Some of
these communities didn't have power or telephone, so the
setup ran over 802.11 over distances of up to 23Km using
solar cells for power.  I don't recall exactly, but I think
the embedded box was using a 486 equivalent.  I think they
had around 40 of these things up and going.

The point of the story is there are people out there who
use Linux on small processors, and often do imaginative 
things with them.  We would be doing them a disservice by 
ripping out the code.

> On other side I see no problem with attached patches. Have you tested 
> patched kernel with old "tc" tool ?

Yes.

