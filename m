From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH net-next 3/6] [BNX2]: Remove the rx_offset field
 from the bnx2 structure.
Date: Fri, 16 May 2008 15:07:09 -0700
Message-ID: <1210975629.5938.12.camel@dell>
References: <1210973417.5507.19.camel@dell>
 <20080516202942.GJ28241@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, andy@greyhouse.net,
	benli@broadcom.com
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2213 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762229AbYEPVC1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2008 17:02:27 -0400
In-Reply-To: <20080516202942.GJ28241@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-05-16 at 21:29 +0100, Ben Hutchings wrote:
> > +#define BNX2_RX_OFFSET               sizeof(struct l2_fhdr) + 2
> 
> The definition needs parentheses around it.  You would get away this
> except for this one place where BNX2_RX_OFFSET is subtracted.

Good point.  The bug would cause the jumbo threshold to be off by 2.  
It would not make much difference in this particular case.

Thanks for spotting this and I'll generate a new patch.

