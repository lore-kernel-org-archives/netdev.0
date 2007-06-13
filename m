From: Oliver Neukum <oliver@neukum.org>
Subject: Re: cannot set IP for ethernet
Date: Wed, 13 Jun 2007 13:55:27 +0200
Message-ID: <200706131355.27574.oliver@neukum.org>
References: <200706121441.13561.oliver@neukum.org> <200706131321.30451.oliver@neukum.org> <466FD439.2040807@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out001.kontent.com ([81.88.40.215]:53308 "EHLO
	smtp-out.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757274AbXFMLzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 07:55:53 -0400
In-Reply-To: <466FD439.2040807@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Mittwoch, 13. Juni 2007 schrieb Patrick McHardy:
> Oliver Neukum wrote:
> > Am Mittwoch, 13. Juni 2007 schrieb Patrick McHardy:
> >>>>
> >>>>This can happen if the initial inetdev allocation when the netdevice is
> >>>>registered fails. I think it would make sense to try to allocate again
> >>>>when adding addresses in that case, otherwise there is no way of
> >>>>recovery other than unregistering and registering the device again.
> >>>
> >>>
> >>>With your patch the problem has gone away. Is there a way to especially
> >>>stress the system in that regard?
> >>
> >>
> >>Its a failed allocation at NETDEV_REGISTER time. I guess you could
> >>keep unloading + reloading the driver module to try to reproduce it.
> > 
> > 
> > If that is the cause, why doesn't it strike from the very beginning? How
> > come it fails after some time?
> 
> 
> It might also be a failed in_ifaddr allocation. In that case my patch
> shouldn't help though.

The problem is that I don't know how to provoke the failure. I might
be doing another workload today than yesterday. Perhaps I should
do several compilations like yesterday?

	Regards
		Oliver

