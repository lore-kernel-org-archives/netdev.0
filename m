From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH 5/7] xen-netfront: reduce gso_max_size to account for
 ethernet header
Date: Fri, 12 Apr 2013 14:29:57 +0100
Message-ID: <20130412132957.GG11321@zion.uk.xensource.com>
References: <1365505655-8021-1-git-send-email-wei.liu2@citrix.com>
 <1365505655-8021-6-git-send-email-wei.liu2@citrix.com>
 <20130411200401.GJ5936@zion.uk.xensource.com>
 <1365754684.8126.82.camel@zakaz.uk.xensource.com>
 <20130412084822.GA11321@zion.uk.xensource.com>
 <1365757035.15783.4.camel@zakaz.uk.xensource.com>
 <20130412093433.GD11321@zion.uk.xensource.com>
 <1365759801.15783.11.camel@zakaz.uk.xensource.com>
 <1365771499.4459.2.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	David Vrabel <david.vrabel@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	"wdauchy@gmail.com" <wdauchy@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:62451 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753798Ab3DLN37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 09:29:59 -0400
Content-Disposition: inline
In-Reply-To: <1365771499.4459.2.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 12, 2013 at 01:58:19PM +0100, Eric Dumazet wrote:
> On Fri, 2013-04-12 at 10:43 +0100, Ian Campbell wrote:
> > On Fri, 2013-04-12 at 10:34 +0100, Wei Liu wrote:
> 
> > > But we don't have handle on this. If I understand correctly the
> > > discussion in other thread, 90 is empirical value, not something
> > > documented.
> > 
> > My original question was effectively "is anyone else going to be
> > interested in this empirical value", if so then it seems like it would
> > be useful to have it centrally defined.
> > 
> 
> This could be MAX_TCP_HEADER. Probably a bit overestimated but do we
> care ?
> 

I don't think we care. MAX_TCP_HEADER is as good as any. Reserving a few
more bytes won't hurt. I just want to make sure the value doesn't look
like something randomly comes up in my mind. :-)

Ian, what do you think?


Wei.
