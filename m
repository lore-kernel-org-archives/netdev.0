From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 2/14] nes: device structures and defines
Date: Wed, 8 Aug 2007 13:50:35 +0200
Message-ID: <200708081350.36081.mb@bu3sch.de>
References: <200708080045.l780jE9E004667@neteffect.com> <46B918BA.2020400@garzik.org> <p73hcnarykt.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, ggrundstrom@neteffect.com,
	rdreier@cisco.com, ewg@lists.openfabrics.org,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:34595
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752563AbXHHLvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 07:51:16 -0400
In-Reply-To: <p73hcnarykt.fsf@bingen.suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 08 August 2007 14:38:10 Andi Kleen wrote:
> Jeff Garzik <jeff@garzik.org> writes:
> > > +			val, reg_index, addr, addr+4); */
> > > +	writel(cpu_to_le32(reg_index), addr);
> > > +	writel(cpu_to_le32(val),(u8 *)addr + 4);
> > 
> > wrong -- endian conversion macros not needed with writel()
> 
> Are you sure? I don't think that's true. e.g. powerpc writel 
> doesn't convert endian

Andi, you are wrong.
writeX take CPU endian args.

-- 
Greetings Michael.
