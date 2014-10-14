From: vadim4j@gmail.com
Subject: Re: [PATCH net-next] Allow to set net namespace for wireless device
 via RTM_LINK
Date: Tue, 14 Oct 2014 15:16:27 +0300
Message-ID: <20141014121627.GA5115@angus-think.lan>
References: <1410467723-2550-1-git-send-email-vadim4j@gmail.com>
 <1411075535.2034.5.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:55453 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755214AbaJNMZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 08:25:16 -0400
Content-Disposition: inline
In-Reply-To: <1411075535.2034.5.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 18, 2014 at 11:25:35PM +0200, Johannes Berg wrote:
> On Thu, 2014-09-11 at 23:35 +0300, Vadim Kochan wrote:
> > Added new netdev_ops callback for setting namespace in specific
> > for this device way
> 
> > +++ b/include/linux/netdevice.h
> > @@ -997,6 +997,8 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
> >   *	Callback to use for xmit over the accelerated station. This
> >   *	is used in place of ndo_start_xmit on accelerated net
> >   *	devices.
> > + * int (*ndo_set_netns)(struct net_device *dev, struct net *net);
> > + *      Callback to set net namespace in specific way for this device.
> 
> For the record, I don't consider it appropriate to set the net namespace
> on one netdev and end up with multiple netdevs switching namespaces ...
> 
> As a result, I don't think this should done.
> 
> johannes
> 

The reason for this was to make possible to change netns for wireless
dev via 'ip link' too like for 'iw' util. I just think that changing
namespace for netdev should have the generic way. May be you can suggest
a better way

Thanks,
