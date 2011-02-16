From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: Re: [PATCH] bnx2x: Support for managing RX indirection table
Date: Wed, 16 Feb 2011 07:53:38 +0200
Message-ID: <201102160753.38598.vladz@broadcom.com>
References: <alpine.DEB.2.00.1102150815060.27695@pokey.mtv.corp.google.com>
 <1297788529.2584.12.camel@bwh-desktop>
 <AANLkTi=VT7BMpJZeE_gKOceNw+=Db40p3znmyt=Jc2Un@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Ben Hutchings" <bhutchings@solarflare.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Tom Herbert" <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2835 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751330Ab1BPFxx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Feb 2011 00:53:53 -0500
In-Reply-To: <AANLkTi=VT7BMpJZeE_gKOceNw+=Db40p3znmyt=Jc2Un@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 16 February 2011 00:50:18 Tom Herbert wrote:
> >> +     u32                     rx_indir_table[128];
> >
> > Shouldn't the dimension be TSTORM_INDIRECTION_TABLE_SIZE?
> >
> 
> It's not a defined constant, so the alternative would be to malloc it
> which seems like overkill to me.
> 
> Broadcom guys: are there any adapters or configuration of bnx2x where
> the indirection table would be greater than 128?

Although for all currently supported adapters the actual value of the indirection 
table size is 128 I agree with Ben and would like to ask u to use the above macro (which
is a rename for an entry in a per-adapter array of constants) to keep the code 
scalable and clean. I don't think that a malloc would be too much of a price for it... ;)

thanks,
vlad

> 
> Tom
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 

