From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/14] nes: device structures and defines
Date: Wed, 08 Aug 2007 15:04:17 -0700 (PDT)
Message-ID: <20070808.150417.18560992.davem@davemloft.net>
References: <200708080045.l780jE9E004667@neteffect.com>
	<46B918BA.2020400@garzik.org>
	<p73hcnarykt.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, ggrundstrom@neteffect.com, rdreier@cisco.com,
	ewg@lists.openfabrics.org, netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49728
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758532AbXHHWER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 18:04:17 -0400
In-Reply-To: <p73hcnarykt.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: 08 Aug 2007 14:38:10 +0200

> Jeff Garzik <jeff@garzik.org> writes:
> > > +			val, reg_index, addr, addr+4); */
> > > +	writel(cpu_to_le32(reg_index), addr);
> > > +	writel(cpu_to_le32(val),(u8 *)addr + 4);
> > 
> > wrong -- endian conversion macros not needed with writel()
> 
> Are you sure? I don't think that's true. e.g. powerpc writel 
> doesn't convert endian

raw_writel() doesn't, but writel() does.

Why not look at the code, as I did, instead of "think"ing? :-)
