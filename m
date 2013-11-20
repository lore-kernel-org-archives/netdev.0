From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next RFC v2 2/2] ipv6 addrconf: introduce IFA_F_MANAGETEMPADDR to tell kernel to manage temporary addresses
Date: Wed, 20 Nov 2013 17:05:43 +0100
Message-ID: <20131120160543.GV16541@order.stressinduktion.org>
References: <1384857809-6573-1-git-send-email-jiri@resnulli.us> <1384857809-6573-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	thaller@redhat.com, stephen@networkplumber.org,
	vyasevich@gmail.com, dcbw@redhat.com, David.Laight@ACULAB.COM
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:55086 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753756Ab3KTQFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 11:05:45 -0500
Content-Disposition: inline
In-Reply-To: <1384857809-6573-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 19, 2013 at 11:43:29AM +0100, Jiri Pirko wrote:
> Creating an address with this flag set will result in kernel taking care
> of temporary addresses in the same way as if the address was created by
> kernel itself (after RA receive). This allows userspace applications
> implementing the autoconfiguration (NetworkManager for example) to
> implement ipv6 addresses privacy.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> Signed-off-by: Thomas Haller <thaller@redhat.com>

The patch looks good.

Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

The _bh conversion seems not to be strictly necessary, no?
ipv6_create_tempaddr is always called with bh disabled.

Thanks,

  Hannes
