From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 1/4] xen-netfront: remove unused variable `extra'
Date: Mon, 18 Mar 2013 12:14:20 +0000
Message-ID: <1363608860.30193.39.camel@zakaz.uk.xensource.com>
References: <1363602955-24790-1-git-send-email-wei.liu2@citrix.com>
	 <1363602955-24790-2-git-send-email-wei.liu2@citrix.com>
	 <1363606922.30193.21.camel@zakaz.uk.xensource.com>
	 <1363608271.29093.196.camel@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"annie.li@oracle.com" <annie.li@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:61033 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751129Ab3CRMOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 08:14:24 -0400
In-Reply-To: <1363608271.29093.196.camel@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-03-18 at 12:04 +0000, Wei Liu wrote:
> On Mon, 2013-03-18 at 11:42 +0000, Ian Campbell wrote:
> > On Mon, 2013-03-18 at 10:35 +0000, Wei Liu wrote:
> > 
> > I think a few more words are needed here since from the code you are
> > removing it seems very much like gso is used for something. If you have
> > a proof that the "extra = gso" case is never hit then please explain it.
> > Perhaps a reference to the removal of the last user?
> > 
> > Or maybe it is the case that it should be used and the bug is that it
> > isn't?
> > 
> 
> Looks like the latter one. 'extra' field should  be used to get hold of
> the last extra info in the ring. ;-)
> 
> But, the only extra info in upstream kernel is XEN_NETIF_EXTRA_TYPE_GSO,
> so there's really no other extra info in the ring at that point. Could
> it be possible that it is something from classic Xen kernel?

The classic kernel netfront has exactly the same code it seems and
netif_extra_type_gso is the only one I've ever heard of.

Maybe this extra thing is just redundant unless/until a second extra
comes along.

Ian.
