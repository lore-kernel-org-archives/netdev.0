From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net-next v2] xen-netback: implement dynamic multicast
 control
Date: Tue, 2 Feb 2016 11:48:25 +0000
Message-ID: <9d2b78b8dac54e6ea3f9889fd2a9db83@AMSPEX02CL03.citrite.net>
References: <1454412668-6472-1-git-send-email-paul.durrant@citrix.com>
 <20160202114646.GF10990@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"Ian Campbell" <Ian.Campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([185.25.65.24]:12919 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754972AbcBBLs1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 06:48:27 -0500
In-Reply-To: <20160202114646.GF10990@citrix.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Wei Liu [mailto:wei.liu2@citrix.com]
> Sent: 02 February 2016 11:47
> To: Paul Durrant
> Cc: netdev@vger.kernel.org; xen-devel@lists.xenproject.org; Ian Campbell;
> Wei Liu
> Subject: Re: [PATCH net-next v2] xen-netback: implement dynamic multicast
> control
> 
> On Tue, Feb 02, 2016 at 11:31:08AM +0000, Paul Durrant wrote:
> [...]
> > +static int xen_register_mcast_ctrl_watch(struct xenbus_device *dev,
> > +					 struct xenvif *vif)
> > +{
> > +	int err = 0;
> > +	char *node;
> > +	unsigned maxlen = strlen(dev->otherend) +
> > +		sizeof("/request-multicast-control");
> > +
> > +	if (vif->mcast_ctrl_watch.node)
> > +		return -EADDRINUSE;
> > +
> 
> Sorry if I didn't make myself clear enough. I think EADDRINUSE should
> also be logged.
> 

Ok. Not sure how much noise that will cause though.

  Paul

> Wei.
