From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 5/7] xen-netfront: reduce gso_max_size to account for
 ethernet header
Date: Fri, 12 Apr 2013 14:36:55 +0100
Message-ID: <1365773815.15783.44.camel@zakaz.uk.xensource.com>
References: <1365505655-8021-1-git-send-email-wei.liu2@citrix.com>
	 <1365505655-8021-6-git-send-email-wei.liu2@citrix.com>
	 <20130411200401.GJ5936@zion.uk.xensource.com>
	 <1365754684.8126.82.camel@zakaz.uk.xensource.com>
	 <20130412084822.GA11321@zion.uk.xensource.com>
	 <1365757035.15783.4.camel@zakaz.uk.xensource.com>
	 <20130412093433.GD11321@zion.uk.xensource.com>
	 <1365759801.15783.11.camel@zakaz.uk.xensource.com>
	 <1365771499.4459.2.camel@edumazet-glaptop>
	 <20130412132957.GG11321@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	David Vrabel <david.vrabel@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	"wdauchy@gmail.com" <wdauchy@gmail.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:34909 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753808Ab3DLNg5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 09:36:57 -0400
In-Reply-To: <20130412132957.GG11321@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-12 at 14:29 +0100, Wei Liu wrote:
> On Fri, Apr 12, 2013 at 01:58:19PM +0100, Eric Dumazet wrote:
> > On Fri, 2013-04-12 at 10:43 +0100, Ian Campbell wrote:
> > > On Fri, 2013-04-12 at 10:34 +0100, Wei Liu wrote:
> > 
> > > > But we don't have handle on this. If I understand correctly the
> > > > discussion in other thread, 90 is empirical value, not something
> > > > documented.
> > > 
> > > My original question was effectively "is anyone else going to be
> > > interested in this empirical value", if so then it seems like it would
> > > be useful to have it centrally defined.
> > > 
> > 
> > This could be MAX_TCP_HEADER. Probably a bit overestimated but do we
> > care ?
> > 
> 
> I don't think we care. MAX_TCP_HEADER is as good as any. Reserving a few
> more bytes won't hurt. I just want to make sure the value doesn't look
> like something randomly comes up in my mind. :-)
> 
> Ian, what do you think?

It could be up to 256 bytes from the looks of things, depending
on .config. That's probably ok.

Ian.
