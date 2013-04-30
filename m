From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] Add support for netconsole driver used on bridge device
 with VIF attached
Date: Tue, 30 Apr 2013 15:24:02 +0100
Message-ID: <1367331842.3142.546.camel@zakaz.uk.xensource.com>
References: <5757e54b-902b-4338-8ac9-43857cd1906c@default>
	 <50FD8243.6000501@oracle.com>
	 <1358846612.3279.282.camel@zakaz.uk.xensource.com>
	 <201301291054.46405.yuval.shaia@oracle.com>
	 <1359455385.12252.85.camel@zakaz.uk.xensource.com>
	 <1367232145.26060.1.camel@yuval-pc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Yuval Shaia <yuval.shaia@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:52006 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760656Ab3D3OYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 10:24:05 -0400
In-Reply-To: <1367232145.26060.1.camel@yuval-pc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-29 at 11:42 +0100, Yuval Shaia wrote:
> Can you suggest how to continue from here? as i don't see any comment on
> that issue up to now.

Please can you resend the patch with an extended changelog based on the
discussions in this thread and CC the bridge folks as well.

Ian.

> Yuval
> > 
> > AFAICT the only reason to actually support netpoll in netback would be
> > if you wanted host logs to go to a listener running in a domain on the
> > same host, which sounds like a mad idea to me! If someone actually has a
> > real need for that use case and can test that it works I'd be happy to
> > reconsider this patch on that basis (assuming the necessary #ifdefs are
> > added as mentioned before).
> > 
> > > > BTW looking at the patch as it is any use of this hook should be wrapped
> > > > in CONFIG_NET_POLL_CONTROLLER.
> > > > 
> > > > Ian.
> > > > 
> > > 
> > > 
> > 
> > 
> 
> 
> 
