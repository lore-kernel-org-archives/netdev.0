From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 2/14] nes: device structures and defines
Date: Wed, 8 Aug 2007 14:55:11 +0200
Message-ID: <20070808125511.GA14419@one.firstfloor.org>
References: <200708080045.l780jE9E004667@neteffect.com> <46B918BA.2020400@garzik.org> <p73hcnarykt.fsf@bingen.suse.de> <200708081350.36081.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, Jeff Garzik <jeff@garzik.org>,
	ggrundstrom@neteffect.com, rdreier@cisco.com,
	ewg@lists.openfabrics.org, netdev@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:59739 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752610AbXHHMzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 08:55:13 -0400
Content-Disposition: inline
In-Reply-To: <200708081350.36081.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 08, 2007 at 01:50:35PM +0200, Michael Buesch wrote:
> On Wednesday 08 August 2007 14:38:10 Andi Kleen wrote:
> > Jeff Garzik <jeff@garzik.org> writes:
> > > > +			val, reg_index, addr, addr+4); */
> > > > +	writel(cpu_to_le32(reg_index), addr);
> > > > +	writel(cpu_to_le32(val),(u8 *)addr + 4);
> > > 
> > > wrong -- endian conversion macros not needed with writel()
> > 
> > Are you sure? I don't think that's true. e.g. powerpc writel 
> > doesn't convert endian
> 
> Andi, you are wrong.
> writeX take CPU endian args.

That is what I wrote.

-Andi
