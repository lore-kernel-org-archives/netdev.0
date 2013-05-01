From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH iproute2] ip: ipv6: add tokenized interface identifier support
Date: Wed, 1 May 2013 16:16:45 +0200
Message-ID: <20130501141645.GC15555@order.stressinduktion.org>
References: <1367338970-2168-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44528 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751090Ab3EAOQt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 10:16:49 -0400
Content-Disposition: inline
In-Reply-To: <1367338970-2168-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 30, 2013 at 06:22:50PM +0200, Daniel Borkmann wrote:
> This patch adds support for tokenized IIDs, that enable
> administrators to assign well-known host-part addresses
> to nodes whilst still obtaining global network prefix
> from Router Advertisements. This is the iproute2 part for
> the kernel patch f53adae4eae5 (``net: ipv6: add tokenized
> interface identifier support'').
> 
> Example commands with iproute2:
> 
> Setting a device token:
>   # ip token set ::1a:2b:3c:4d/64 dev eth1
> 
> Getting a device token:
>   # ip token get dev eth1
>   token ::1a:2b:3c:4d dev eth1
> 
> Listing all tokens:
>   # ip token list  (or: ip token)
>   token :: dev eth0
>   token ::1a:2b:3c:4d dev eth1
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks!
