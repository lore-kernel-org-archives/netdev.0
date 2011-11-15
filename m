From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: fixes for DSACK-based undo of cwnd reduction during
 fast recovery
Date: Tue, 15 Nov 2011 08:13:13 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1111150736480.24369@melkinpaasi.cs.helsinki.fi>
References: <1320775631-16341-1-git-send-email-ncardwell@google.com> <20111114.152359.1131974895743731960.davem@davemloft.net> <CADVnQyn7czRocYV3-goTtwqCDg9MBv+bTHeZ-A8R4n45LH8L=g@mail.gmail.com> <alpine.DEB.2.00.1111150333360.24223@melkinpaasi.cs.helsinki.fi>
 <CADVnQykYW1kBopj2qpy8gt4gWejn+2k2YJg-UDHZ8uUxBXw5Zw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="8323329-1603620124-1321335620=:24369"
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, nanditad@google.com,
	ycheng@google.com, therbert@google.com
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55517 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751642Ab1KOGNP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 01:13:15 -0500
In-Reply-To: <CADVnQykYW1kBopj2qpy8gt4gWejn+2k2YJg-UDHZ8uUxBXw5Zw@mail.gmail.com>
Content-ID: <alpine.DEB.2.00.1111150740270.24369@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1603620124-1321335620=:24369
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.1111150740271.24369@melkinpaasi.cs.helsinki.fi>

On Tue, 15 Nov 2011, Neal Cardwell wrote:
> On Mon, Nov 14, 2011 at 9:05 PM, Ilpo Järvinen
> <ilpo.jarvinen@helsinki.fi> wrote:
> >
> > When you need to say "fixes 1), 2), and 3)", please stop for a moment
> > thinking if the fixes really need to be sent as one fix or 3 fixes (a
> > series PATCH x/3, see netdev for examples). It would make review much
> > simpler if unrelated fixes are not put together even if all of them
> > would be needed to get DSACK working as intented.
> 
> I'm happy to split this patch into a few smaller patches. I was on the
> fence about how fine-grained to make them; I'll make them smaller.

Thanks. In fixes smaller is almost always better. You can then state per 
fix very exactly what is wrong in the code and in what scenario that 
causes problem to materialize for real. Smallness helps the review 
enourmously and all questions raised against can then also remain more 
focused (possibly the rest could be acked/applied immediately, which 
happens quite often actually). You will be surprised yourself too then, 
once you've split each patch becomes very obvious and short (and then I'll 
be more lax about the commit message too as the diff speaks more 
succesfully for itself ;-)).

-- 
 i.
--8323329-1603620124-1321335620=:24369--
