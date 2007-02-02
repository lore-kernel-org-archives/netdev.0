From: Shinta Sugimoto <shinta@sfc.wide.ad.jp>
Subject: Re: (usagi-core 32165) Re: [RFC][PATCH][XFRM][4/5] extension to XFRM for dynamic endpoint update (MIGRATE)
Date: Fri, 02 Feb 2007 21:10:09 +0900
Message-ID: <20070202210442.E2F9.SHINTA@sfc.wide.ad.jp>
References: <20070201114558.E2C3.SHINTA@sfc.wide.ad.jp> <Pine.LNX.4.64.0702010947530.8524@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Francis Dupont <Francis.Dupont@point6.net>,
	Masahide Nakamura <nakam@linux-ipv6.org>
To: usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sfc.wide.ad.jp ([203.178.142.146]:36190 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423039AbXBBMKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Feb 2007 07:10:15 -0500
In-Reply-To: <Pine.LNX.4.64.0702010947530.8524@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 1 Feb 2007 09:50:00 -0500 (EST)
James Morris <jmorris@namei.org> wrote:

> On Thu, 1 Feb 2007, Shinta Sugimoto wrote:
> 
> > +	/* allow IPSEC_PROTO_ANY to match all protocols */
> > +	//sel.proto = pfkey_proto_to_xfrm(sa->sadb_address_proto);
> > +	sel.proto = sa->sadb_address_proto;
> 
> Which one is correct ? :-)

Thank you for point this out.  The following should be correct.

sel.proto = pfkey_proto_to_xfrm(sa->sadb_address_proto);

> 
> > +	/* allow IPSEC_PROTO_ANY to match all protocols */
> > +	//sel.proto = pfkey_proto_to_xfrm(sa->sadb_address_proto);
> > +	sel.proto = sa->sadb_address_proto;
> 
> ...

Same for this one. I will fix them.


Regards,
Shinta

