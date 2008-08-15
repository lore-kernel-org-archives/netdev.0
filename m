From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH 1/1] tun: TUNGETIFF interface to query name and flags
Date: Fri, 15 Aug 2008 15:02:24 +0100
Message-ID: <1218808944.3751.81.camel@muff>
References: <1218637816.29159.31.camel@muff>
	 <200808141158.57879.rusty@rustcorp.com.au>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"virtualization@lists.osdl.org" <virtualization@lists.osdl.org>,
	Rusty Russell <rusty@rustcorp.com.au>
To: maxk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52846 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753399AbYHOOC7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Aug 2008 10:02:59 -0400
In-Reply-To: <200808141158.57879.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-08-14 at 11:58 +1000, Rusty Russell wrote:
> On Thursday 14 August 2008 00:30:16 Mark McLoughlin wrote:
> > A very simple approach is attached; I did consider doing a TUNGETFLAGS
> > that would return tun->flags, but I think it's nicer to have a companion
> > to TUNGETIFF since it also allows one to query the interface name from
> > the file descriptor.
> 
> This seems really sensible to me.
> 
> If Max acks it,

How about it Max?

Trying a different email address - previous mail at:

  http://marc.info/?l=linux-netdev&m=121863813904363

> I'd say Dave should merge it.

Maybe it's too late already, but I'm really hoping to get this in
2.6.27.

Without it, the IFF_VNET_HDR goodness already added in 2.6.27 can't be
used by KVM guests created by libvirt ... which is a good chunk of the
potential users for this stuff.

Cheers,
Mark.

