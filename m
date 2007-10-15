From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH][BNX2X] round three
Date: Mon, 15 Oct 2007 14:58:29 -0700
Message-ID: <20071015145829.1acabefb@freepuppy.rosehill>
References: <p73641c4cfz.fsf@bingen.suse.de>
	<20071012.150341.41635825.davem@davemloft.net>
	<1192462049.29746.158.camel@eliezer>
	<20071015.123850.26516814.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eliezert@broadcom.com, andi@firstfloor.org, netdev@vger.kernel.org,
	jeff@garzik.org, mchan@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:43873 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932091AbXJOV6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 17:58:48 -0400
In-Reply-To: <20071015.123850.26516814.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 15 Oct 2007 12:38:50 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: "Eliezer Tamir" <eliezert@broadcom.com>
> Date: Mon, 15 Oct 2007 17:27:29 +0200
> 
> > Unfortunately, the firmware code is different for LE and BE machines.
> > We had issues with the BE firmware that appear to be resolved.
> > Hopefully, the next version will have both.
> 
> If this means we get two copies of the firmware, this should be
> rethought.  The space cost of the firmware (both in terms of source
> code size and object code size) is already enormous.
> 
> I would definitely prefer if there were only little-endian firmware,
> and the driver uses "cpu_to_le32()" and friends to access chip shared
> data structures.
> 
> Most cpus have endian swapping loads and stores, accessible via
> cpu_to_le32p() and similar interfaces, so the cost on big-endian of
> doing things this way is very close to zero.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

What about using loadable firmware rather than building it into the driver?


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
