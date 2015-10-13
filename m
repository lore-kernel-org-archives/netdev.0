From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next v5 01/10] qed: Add module with basic common
 support
Date: Tue, 13 Oct 2015 23:54:29 +0200
Message-ID: <20151013215429.GA4378@electric-eye.fr.zoreil.com>
References: <1444674622-13059-1-git-send-email-Yuval.Mintz@qlogic.com>
 <1444674622-13059-2-git-send-email-Yuval.Mintz@qlogic.com>
 <20151012230750.GA7378@electric-eye.fr.zoreil.com>
 <B5657A6538887040AD3A81F1008BEC63E467D6@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:47231 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751512AbbJMVzH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 17:55:07 -0400
Content-Disposition: inline
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63E467D6@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yuval Mintz <Yuval.Mintz@qlogic.com> :
[...]
> > > +struct qed_simd_fp_handler {
> > > +     void    *token;
> > > +     void    (*func)(void *);
> > > +};
> > Use union * ?
> The token is a cookie to be used by a func, so union isn't appropriate.

Lets' reformulate: replace 'void * token' by 'union foobar *token'.

void * silents compiler. union * doesn't.

[...]
> > > +             rc = -ENOMEM;
> > > +             goto ilt_shadow_fail;
> > > +     } else {
> > > +             DP_VERBOSE(p_hwfn, QED_MSG_ILT,
> > > +                        "Allocated 0x%x bytes for ilt shadow\n",
> > > +                        (u32)(size * sizeof(struct qed_dma_mem)));
> > > +     }
> > The "else" branch after the "goto" isn't idiomatic.
> Not that I mind, but is such a prefernce described in any style-guide?

Documentation/CodingStyle gives some hints in its "goto" section but it
doesn't specifically go that far. Is there a reward if I can exhumate
some message on netdev where it would had already been outlined ?

-- 
Ueimor
