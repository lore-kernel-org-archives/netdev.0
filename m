From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] inet: remove now unused flag DST_NOPEER
Date: Thu, 06 Mar 2014 03:59:59 -0800
Message-ID: <1394107199.27473.25.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140306081107.GD26307@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:51795 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751650AbaCFMAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 07:00:00 -0500
Received: by mail-pb0-f54.google.com with SMTP id ma3so2547918pbc.27
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2014 04:00:00 -0800 (PST)
In-Reply-To: <20140306081107.GD26307@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-03-06 at 09:11 +0100, Hannes Frederic Sowa wrote:
> Commit e688a604807647 ("net: introduce DST_NOPEER dst flag") introduced
> DST_NOPEER because because of crashes in ipv6_select_ident called from
> udp6_ufo_fragment.
> 
> Since commit 916e4cf46d0204 ("ipv6: reuse ip6_frag_id from
> ip6_ufo_append_data") we don't call ipv6_select_ident any more from
> ip6_ufo_append_data, thus this flag lost its purpose and can be removed.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---

SGTM

Acked-by: Eric Dumazet <edumazet@google.com>
