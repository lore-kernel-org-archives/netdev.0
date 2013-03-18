From: Dan Williams <dcbw@redhat.com>
Subject: Re: Who/What is supposed to remove IPv6 address from interface when
 moving from one network to another ?
Date: Mon, 18 Mar 2013 15:42:46 -0500
Message-ID: <1363639366.7698.10.camel@dcbw.foobar.com>
References: <CAF6-1L4=xACZdqvJ6AZL4XkY17N0pC9PnPfNfK9Tk7QB47c1tw@mail.gmail.com>
	 <CAF6-1L5cxguK8tHxjMACZJ8xNmAXLLXwP086eF4_SEctZdiZ3g@mail.gmail.com>
	 <1363290495.1643.29.camel@dcbw.foobar.com>
	 <CAKD1Yr1=1kfcSmRYgnrYQBhNPPc=nquB2c1jLbopbvqz848cxQ@mail.gmail.com>
	 <1363626191.6437.2.camel@dcbw.foobar.com>
	 <CAF6-1L7De=QQz9YnRxqovnoxzfR0WHnQ-Fi4T_LZ+j9s=oQWyA@mail.gmail.com>
	 <CAKD1Yr1Dd0ngiB0WhEQCjCrrEVrtqs9VuHPWukCdupkfLWjqaQ@mail.gmail.com>
	 <CAF6-1L7Von88pAhHzhyaJiL8x4w9cNpJw+k+0Giu5Jh-fYJ37g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Lorenzo Colitti <lorenzo@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sylvain Munaut <s.munaut@whatever-company.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50165 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754098Ab3CRUlz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Mar 2013 16:41:55 -0400
In-Reply-To: <CAF6-1L7Von88pAhHzhyaJiL8x4w9cNpJw+k+0Giu5Jh-fYJ37g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-03-18 at 19:28 +0100, Sylvain Munaut wrote:
> Hi,
> 
> >> This might be a dumb idea but, would it make sense for the kernel not
> >> to use as source address, an address generated from a prefix for which
> >> the route has expired ?
> >
> > The route doesn't expire either. (And neither does the default gateway).
> 
> Ah sorry.
> 
> In my case the router lifetime is much shorter ( a few minutes ) and
> expired by the time I get home, which is why I was only faced with the
> "using bad source address" issue.
> 
> In anycase, following Dan's reponse, I just flush all ipv6 on suspend
> now ... (NetworkManager was a bit heavy-weight to just sort that
> particular issue ...)

While I'm not an IPv6 expert I would actually expect the kernel to stop
using any IPv6 address or route that had expired, and that was *added
automatically* by the kernel as a result of a router advertisement.
Perhaps that's not how it actually works, but would be nice to hear from
some kernel IPv6 people why that's not how it works, if that's the case.

Dan
