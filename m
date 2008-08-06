From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: few more fixes for iproute2/m_ipt
Date: Wed, 6 Aug 2008 15:56:44 +0300
Message-ID: <200808061556.45351.denys@visp.net.lb>
References: <200808060042.53503.denys@visp.net.lb> <200808061550.42003.denys@visp.net.lb> <1218027312.4755.63.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:32962 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752796AbYHFM5e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 08:57:34 -0400
In-Reply-To: <1218027312.4755.63.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 06 August 2008, jamal wrote:
> On Wed, 2008-06-08 at 15:50 +0300, Denys Fedoryshchenko wrote:
> > +       /* Clear flags if target will be used again */
> > +        m->tflags=0;
> > +        m->used=0;
> > +       /* Free allocated memory */
> > +        if (m->t)
> > +            free(m->t);
> > +
>
> I meant moving the above to 02-iproute-optind_zero.patch
>
> No big deal if you dont have time.
>
> cheers,
> jamal

No problem with that, i will do now patch.
