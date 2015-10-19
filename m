From: Michael Chan <mchan@broadcom.com>
Subject: Re: [PATCH net-next v3] bnxt_en: New Broadcom ethernet driver.
Date: Mon, 19 Oct 2015 16:04:02 -0700
Message-ID: <1445295842.7588.26.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1445055704-6103-1-git-send-email-mchan@broadcom.com>
	 <20151018221958.1b7b9d0d@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <prashant@broadcom.com>,
	<eddie.wai@broadcom.com>, <huangjw@broadcom.com>,
	<netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:6690 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751285AbbJSXE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 19:04:29 -0400
In-Reply-To: <20151018221958.1b7b9d0d@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-10-18 at 22:19 -0700, Stephen Hemminger wrote: 
> On Sat, 17 Oct 2015 00:21:44 -0400
> Michael Chan <mchan@broadcom.com> wrote:
> 
> > +static bool bnxt_vf_pciid(int idx)
> > +{
> > +	if (idx == BCM57304_VF || idx == BCM57404_VF)
> > +		return true;
> > +	return false;
> > +}
> > +
> 
> I prefer just returning result of logical operation
> rather than adding unnecessary if statement.
> And never use (signed) int when unsigned is the real
> data type. Also avoid any unnecessary expansion of 16 bit
> value.
> 
> static bool bnxt_vf_pciid(u16 idx)
> {
> 	return (idx == BCM57304_VF || idx == BCM57404_VF);
> }

idx is actually type enum.  Other points well taken.
