From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 4/8] net: ipv6: mld: implement RFC3810 MLDv2 mode only
Date: Tue, 3 Sep 2013 20:12:55 +0200
Message-ID: <20130903181255.GF21729@order.stressinduktion.org>
References: <1378195178-21002-1-git-send-email-dborkman@redhat.com> <1378195178-21002-5-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35149 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753889Ab3ICSM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 14:12:57 -0400
Content-Disposition: inline
In-Reply-To: <1378195178-21002-5-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 03, 2013 at 09:59:34AM +0200, Daniel Borkmann wrote:
> RFC3810, 10. Security Considerations says under subsection 10.1.
> Query Message:
> 
>   A forged Version 1 Query message will put MLDv2 listeners on that
>   link in MLDv1 Host Compatibility Mode. This scenario can be avoided
>   by providing MLDv2 hosts with a configuration option to ignore
>   Version 1 messages completely.
> 
> Hence, implement a MLDv2-only mode that will ignore MLDv1 traffic:
> 
>   echo 2 > /proc/sys/net/ipv6/conf/ethX/force_mld_version
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
