From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 2/14] nes: device structures and defines
Date: 08 Aug 2007 14:38:10 +0200
Message-ID: <p73hcnarykt.fsf@bingen.suse.de>
References: <200708080045.l780jE9E004667@neteffect.com>
	<46B918BA.2020400@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ggrundstrom@neteffect.com, rdreier@cisco.com,
	ewg@lists.openfabrics.org, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:52361 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751196AbXHHLnv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Aug 2007 07:43:51 -0400
In-Reply-To: <46B918BA.2020400@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jeff@garzik.org> writes:
> > +			val, reg_index, addr, addr+4); */
> > +	writel(cpu_to_le32(reg_index), addr);
> > +	writel(cpu_to_le32(val),(u8 *)addr + 4);
> 
> wrong -- endian conversion macros not needed with writel()

Are you sure? I don't think that's true. e.g. powerpc writel 
doesn't convert endian

-Andi

