From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH V4 7/7] xen-netback: don't disconnect frontend when
 seeing oversize packet
Date: Mon, 15 Apr 2013 16:35:04 +0100
Message-ID: <1366040104.8399.85.camel@zakaz.uk.xensource.com>
References: <1365776646-10796-1-git-send-email-wei.liu2@citrix.com>
	 <1365776646-10796-8-git-send-email-wei.liu2@citrix.com>
	 <CAJ75kXb1Pc83sAjqDuzeGiikTcqdqrgPTxTT7kS-agUqoZp7LA@mail.gmail.com>
	 <1366016605.4963.6.camel@zakaz.uk.xensource.com>
	 <20130415145320.GE17602@zion.uk.xensource.com>
	 <1366039489.8399.83.camel@zakaz.uk.xensource.com>
	 <20130415153038.GI17602@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: William Dauchy <wdauchy@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xen.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"jbeulich@suse.com" <jbeulich@suse.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:14202 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934470Ab3DOPfG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 11:35:06 -0400
In-Reply-To: <20130415153038.GI17602@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> > > Are mechinical fixes such as removing redudent variables / changing log
> > > messages candidates for stable? 1-4 are such kind of fixes.
> > 
> > #4 looks like meat to me too?
> > 
> 
> Not really. DaveM applied first 3 and later I discoverd there was a log
> message which should have been changed in 2. So I wrote a incremental
> patch on top of 2 to fix that.

Oops, I think I read "V4 7/7" as 4/7...

> 
> > My personal opinion is that it is better where possible to take
> > relatively simple and/or obvious precursors (renaming and such fit this
> > IMHO) than to risk making a mistake in the backport.
> > 
> 
> OK, then the whole series is candidate for stable.

Once things go in can you enumerate the actual commit numbers please?

Ian.
