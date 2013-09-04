From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: xen-netback: count number required slots for an skb more
 carefully
Date: Wed, 4 Sep 2013 09:36:10 +0100
Message-ID: <1378283770.17510.52.camel@kazak.uk.xensource.com>
References: <1378229390-12919-1-git-send-email-david.vrabel@citrix.com>
	 <20130903215328.GA13465@zion.uk.xensource.com>
	 <52269A37.7030600@oracle.com>
	 <20130904060446.GA25227@u109add4315675089e695.ant.amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: annie li <annie.li@oracle.com>, Wei Liu <wei.liu2@citrix.com>,
	"David Vrabel" <david.vrabel@citrix.com>,
	<xen-devel@lists.xen.org>,
	"Konrad Rzeszutek Wilk" <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	<netdev@vger.kernel.org>, <msw@amazon.com>
To: Matt Wilson <msw@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:10089 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934343Ab3IDIgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 04:36:12 -0400
In-Reply-To: <20130904060446.GA25227@u109add4315675089e695.ant.amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-03 at 23:04 -0700, Matt Wilson wrote:
> On Wed, Sep 04, 2013 at 10:25:59AM +0800, annie li wrote:
> > On 2013-9-4 5:53, Wei Liu wrote:
> [...]
> > >Matt, do you fancy sending the final version? IIRC the commit message
> > >needs to be re-written. I personally still prefer Matt's solution as
> > >it a) make efficient use of the ring, b) uses ring pointers to
> > >calculate slots which is most accurate, c) removes the dependence on
> > >MAX_SKB_FRAGS in guest RX path.
> > >
> > >Anyway, we should get this fixed ASAP.

Yes. Would there be any harm in just applying David's patch (just
because it is the one currently in our hands and it is based on a recent
enough kernel). It looks right from a correctness PoV to me.

> > Totally agree. This issue is easy to be reproduced with large MTU.
> > It is better to upstream the fix soon in case others hit it and
> > waste time to fix it.
> 
> I'd like to go with Xi's proposed patch that I posed earlier.

I don't think I saw that, do you have a message-id?

("Xi" is a bit too short for a search on my INBOX unfortunately).

>  The main
> thing that's kept me from sending a final version is lack of time to
> retest against a newer kernel.
> 
> Could someone help out with that? I probably can't get to it until the
> end of the week.
> 
> Sorry for the delay. :-(
> 
> --msw
