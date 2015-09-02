From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net-next] xen-netback: add support for multicast control
Date: Wed, 2 Sep 2015 14:01:53 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD02F5AE451@AMSPEX01CL01.citrite.net>
References: <1441196393-26564-1-git-send-email-paul.durrant@citrix.com>
 <20150902140049.GI18474@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"Ian Campbell" <Ian.Campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([185.25.65.24]:49207 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752893AbbIBOBy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 10:01:54 -0400
In-Reply-To: <20150902140049.GI18474@zion.uk.xensource.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Wei Liu [mailto:wei.liu2@citrix.com]
> Sent: 02 September 2015 15:01
> To: Paul Durrant
> Cc: netdev@vger.kernel.org; xen-devel@lists.xenproject.org; Ian Campbell;
> Wei Liu
> Subject: Re: [PATCH net-next] xen-netback: add support for multicast control
> 
> On Wed, Sep 02, 2015 at 01:19:53PM +0100, Paul Durrant wrote:
> > Xen's PV network protocol includes messages to add/remove ethernet
> > multicast addresses to/from a filter list in the backend. This allows
> > the frontend to request the backend only forward multicast packets
> > which are off interest thus preventing unnecessary noise on the shared
> 
> "of interest"

Ah yes :-)

> 
> > ring.
> >
> [...]
> > +
> > +void xenvif_mcast_flush(struct xenvif *vif)
> 
> Only one cosmetic comment.
> 
> My first impression of this function by looking at the name is that it
> flushes queued multicast packets. Maybe we can rename it to
> xenvif_mcast_addr_list_free ?
> 

Sure.

  Paul

> Wei.
