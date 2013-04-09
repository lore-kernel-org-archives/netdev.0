From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 2/3] net: ipv6: also allow token to be set when device not ready
Date: Tue, 9 Apr 2013 22:37:54 +0200
Message-ID: <20130409203754.GC14572@order.stressinduktion.org>
References: <1365515236-7154-1-git-send-email-dborkman@redhat.com> <1365515236-7154-3-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33419 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935899Ab3DIUhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 16:37:55 -0400
Content-Disposition: inline
In-Reply-To: <1365515236-7154-3-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 09, 2013 at 03:47:15PM +0200, Daniel Borkmann wrote:
> When we set the iftoken in inet6_set_iftoken(), we return -EINVAL
> when the device does not have flag IF_READY. This is however not
> necessary and rather an artificial usability barrier, since we
> simply can set the token despite that, and in case the device is
> ready, we just send out our rs, otherwise ifup et al. will do
> this for us anyway.
> 
> Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
