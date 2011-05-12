From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 15/15] ehea: Remove unused tcp_end field in send WQ
Date: Wed, 11 May 2011 20:12:07 -0700
Message-ID: <1305169927.6124.14.camel@Joe-Laptop>
References: <20110512005213.897432612@samba.org>
	 <20110512005623.854973618@samba.org> <1305167473.6124.11.camel@Joe-Laptop>
	 <20110511.230603.1390935245880337663.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, leitao@linux.vnet.ibm.com, michael@ellerman.id.au,
	jesse@kernel.org, bhutchings@solarflare.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1541 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754565Ab1ELDMK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2011 23:12:10 -0400
In-Reply-To: <20110511.230603.1390935245880337663.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-05-11 at 23:06 -0400, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Wed, 11 May 2011 19:31:13 -0700
> > On Thu, 2011-05-12 at 10:52 +1000, Anton Blanchard wrote:
> >> plain text document attachment (ehea_22.patch)
> >> The tcp_end field is not actually used by the hardware, so there
> >> is no need to set it. 
> >> +++ linux-net/drivers/net/ehea/ehea_qmr.h	2011-05-12 07:48:06.380382084 +1000
> >> @@ -106,7 +106,7 @@ struct ehea_swqe {
> >>  	u8 immediate_data_length;
> >>  	u8 tcp_offset;
> >>  	u8 reserved2;
> >> -	u16 tcp_end;
> >> +	u16 reserved2b;
> >>  	u8 wrap_tag;
> >>  	u8 descriptors;		/* number of valid descriptors in WQE */
> >>  	u16 reserved3;
> > struct ehea_swqe isn't __packed.  Shouldn't it be?
> Please don't mark it __packed unless absolutely necessary :-)

Isn't it read from hardware.
If not, why reserve anything?

