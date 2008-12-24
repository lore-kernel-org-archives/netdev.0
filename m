From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [PATCH 3/5] qlge: bugfix: Fix endian issue regarding shadow registers.
Date: Wed, 24 Dec 2008 10:42:20 -0800
Message-ID: <20081224184220.GA15640@susedev.qlogic.org>
References: <20081224181834.GA15470@susedev.qlogic.org> <1230142896-15533-3-git-send-email-ron.mercer@qlogic.com> <1230143731.3070.2.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:29454 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183AbYLXSmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2008 13:42:20 -0500
Content-Disposition: inline
In-Reply-To: <1230143731.3070.2.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 24, 2008 at 10:35:31AM -0800, Ben Hutchings wrote:
> > +static inline u32 ql_read_sh_reg(const volatile void  *addr)
> >  {
> > -	return *(volatile unsigned int __force *)addr;
> > +	return le32_to_cpu(*(volatile unsigned int __force *)addr);
>=20
> I think that should be:
> 	=EF=BB=BFreturn le32_to_cpu(*(const volatile __le32 *)addr);
>=20
> Ben.

Yes, you're right.  I'll fix that and resend the patches after waiting
for more feedback.

Thanks!
