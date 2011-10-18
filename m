From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH] Fix guest memory leak and panic
Date: Tue, 18 Oct 2011 16:16:41 +0530
Message-ID: <OFB632D60B.6534A38B-ON6525792D.003A1B21-6525792D.003B0DB8@in.ibm.com>
References: <20111018080523.16861.55402.sendpatchset@krkumar2.in.ibm.com>	 <1318927016.16132.49.camel@zakaz.uk.xensource.com> <1318931232.16132.65.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"rusty@rustcorp.com.au" <rusty@rustcorp.com.au>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp08.in.ibm.com ([122.248.162.8]:51910 "EHLO
	e28smtp08.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752207Ab1JRKpa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 06:45:30 -0400
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <krkumar2@in.ibm.com>;
	Tue, 18 Oct 2011 16:15:28 +0530
In-Reply-To: <1318931232.16132.65.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ian Campbell <Ian.Campbell@citrix.com> wrote on 10/18/2011 03:17:11 PM:

> > I think the best thing might be to remove the additional ref taking
from
> > the setter function and audit the previous changes to ensure they
> > conform. I'll do that right away and post a fixup patch ASAP.
>
> Sigh, only one out of the ten callers of (__)skb_frag_set_page expects
> skb_frag_set_page to take a new reference. I think that's pretty
> comprehensive evidence that the current behaviour is unexpected and
> wrong.

Looks good!

Does it make sense to commit both of these patches? The
reason being - my patch becomes a cleanup of set_skb_frag()
in virtio_net driver.

thanks,

- KK
