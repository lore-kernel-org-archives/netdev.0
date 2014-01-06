From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] gre_offload: statically build GRE offloading
 support
Date: Mon, 06 Jan 2014 14:34:55 -0800
Message-ID: <1389047695.26646.10.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1388896679-23152-1-git-send-email-hkchu@google.com>
	 <1389045787.26646.9.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	ogerlitz@mellanox.com, netdev@vger.kernel.org
To: "H.K. Jerry Chu" <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:49869 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755044AbaAFWe5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 17:34:57 -0500
Received: by mail-gg0-f174.google.com with SMTP id v2so3664079ggc.19
        for <netdev@vger.kernel.org>; Mon, 06 Jan 2014 14:34:57 -0800 (PST)
In-Reply-To: <1389045787.26646.9.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-01-06 at 14:03 -0800, Eric Dumazet wrote:

> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: H.K. Jerry Chu <hkchu@google.com>
> ---
> Note : We probably can remove EXPORT_SYMBOL() on inet_add_offload()
> and inet_del_protocol() on a followup patch if there is interest.


There is a typo on this note, of course : inet_del_offload() was
intended, not inet_del_protocol()
