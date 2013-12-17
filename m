From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] xen-netback: add gso_segs calculation
Date: Tue, 17 Dec 2013 14:15:07 -0800
Message-ID: <1387318507.19078.292.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387280675-10295-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f47.google.com ([209.85.213.47]:47251 "EHLO
	mail-yh0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752283Ab3LQWPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 17:15:10 -0500
Received: by mail-yh0-f47.google.com with SMTP id 29so4962097yhl.6
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 14:15:10 -0800 (PST)
In-Reply-To: <1387280675-10295-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-17 at 11:44 +0000, Paul Durrant wrote:
> netback already has code which parses IPv4 and v6 headers to set up checksum
> offsets and these are always applied to GSO packets being sent from
> frontends. It's therefore suboptimal that GSOs are being marked
> SKB_GSO_DODGY to defer the gso_segs calculation when netback already has all
> necessary information to hand to do the calculation. This patch adds that
> calculation.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: David Vrabel <david.vrabel@citrix.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
