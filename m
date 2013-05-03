From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] [PATCH] Add support for netconsole driver used on
 bridge device with VIF attached
Date: Fri, 3 May 2013 15:43:20 +0100
Message-ID: <1367592200.28742.115.camel@zakaz.uk.xensource.com>
References: <1367409301.3301.21.camel@yuval-pc.mtl.com>
	 <1367572270.28742.44.camel@zakaz.uk.xensource.com>
	 <20130503143632.GB3146@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yuval Shaia <yuval.shaia@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	bridge <bridge@lists.linux-foundation.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:39276 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933637Ab3ECOnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 10:43:23 -0400
In-Reply-To: <20130503143632.GB3146@phenom.dumpdata.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-03 at 15:36 +0100, Konrad Rzeszutek Wilk wrote:
> On Fri, May 03, 2013 at 10:11:10AM +0100, Ian Campbell wrote:
> > On Wed, 2013-05-01 at 12:55 +0100, Yuval Shaia wrote:
> > [... snip regurgitation of the thread...]
> > > 0001-Add-support-for-netconsole-driver-used-on-bridge-dev.patch
> > > 0 2001
> > > From: Yuval <yuval.shaia@oracle.com>
> > > Date: Tue, 8 Jan 2013 10:08:45 +0200
> > > Subject: [PATCH] Add support for netconsole driver used on bridge device with
> > >  VIF attached
> > 
> > Sorry, but this is not what I was asking for.
> > 
> > Please submit with a coherent changelog based on (i.e. digested from)
> > the previous discussion which explains why this change is necessary
> > including the background of why it is being made in this way and the
> > interaction with the bridging layer. I wasn't asking you to just cut and
> > paste that discussion and prepend it to the commit like that.
> > 
> > The key point is that we don't think that doing netconsole from dom0 to
> > a domU on the same host is a useful configuration or something which is
> > especially desirable to support but that because of how the bridge
> > handles netconsole netback needs to expose this hook in order that
> > netconsole can be enabled via a physical device on the same bridge to a
> > netserver elsewhere.
> 
> I would have thought that doing netconsole on a domU would be a worthwile
> attempt - especially to troubleshoot a guest?

Yes. But that's not what I said, nor what this patch does.

What this patch enables is dom0 doing netconsole *to* a guest. i.e.
dom0's console going to a guest running on the same host, which is not
an especially useful thing to do.

AFAIK netfront already supports domU netconsole.

Ian.
