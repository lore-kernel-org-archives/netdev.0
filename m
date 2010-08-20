From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [RFC Patch] netxen: remove firmware exports
Date: Fri, 20 Aug 2010 03:53:58 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80F86E692CC@MNEXMB2.qlogic.org>
References: <20100818095908.6606.56224.sendpatchset@localhost.localdomain>
 <99737F4847ED0A48AECC9F4A1974A4B80F86E69208@MNEXMB2.qlogic.org>
 <4C6E423E.5080804@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Dhananjay Phadke <dhananjay.phadke@qlogic.com>,
	Narender Kumar <narender.kumar@qlogic.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:53831 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926Ab0HTIyD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Aug 2010 04:54:03 -0400
In-Reply-To: <4C6E423E.5080804@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Okay. David, do you want me to submit an updated patch?

You have to submit updated patch.

-Amit

> -----Original Message-----
> From: Cong Wang [mailto:amwang@redhat.com]
> Sent: Friday, August 20, 2010 2:22 PM
> To: Amit Salecha
> Cc: linux-kernel@vger.kernel.org; David S. Miller; Dhananjay Phadke;
> Narender Kumar; netdev@vger.kernel.org
> Subject: Re: [RFC Patch] netxen: remove firmware exports
> 
> On 08/19/10 17:12, Amit Salecha wrote:
> >> netxen_nic driver can store firmwares on flash, and get them
> porperly and
> >> dynamically, so the firmwares may not appear in /lib/firmware/.
> However, netxen_nic
> >> still exports these firmwares via modinfo, this makes our script
> which parses
> >> modinfo output fail.
> >
> > NX_UNIFIED_ROMIMAGE_NAME(phanfw.bin) is already submitted and we
> won't submit any other fw files.
> >
> >> -MODULE_FIRMWARE(NX_P2_MN_ROMIMAGE_NAME);
> >> -MODULE_FIRMWARE(NX_P3_CT_ROMIMAGE_NAME);
> >> -MODULE_FIRMWARE(NX_P3_MN_ROMIMAGE_NAME);
> >
> > It's not compulsory to submit firmware files which are exported
> (MODULE_FIRMWARE).
> > I am leaving this upto David to decide about this patch.
> >
> 
> Okay. David, do you want me to submit an updated patch?
> 
> Thanks!
> 
> --
> The opposite of love is not hate, it's indifference.
>   - Elie Wiesel

