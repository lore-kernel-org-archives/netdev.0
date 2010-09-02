From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sky2: don't do GRO on second port
Date: Thu, 2 Sep 2010 08:33:27 +0000
Message-ID: <20100902083327.GA6246@ff.dom.local>
References: <20100830.095012.233695092.davem@davemloft.net> <20100830105117.0f0cf140@nehalam> <20100830190900.GA3141@del.dom.local> <20100901.145151.93454549.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, eric.dumazet@gmail.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:55594 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752520Ab0IBIdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 04:33:35 -0400
Received: by bwz11 with SMTP id 11so373679bwz.19
        for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 01:33:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100901.145151.93454549.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 01, 2010 at 02:51:51PM -0700, David Miller wrote:
> The only scenerio you can guarentee that all packets for a given
> flow key will be treated the same is the one where the input device
> is the same as well.
> 
> When there is a single napi --> device mapping, it works, but without
> that invariant it doesn't.

Do you mean a single napi can't be used eg. for vlan_gro and napi_gro?
(napi_gro handles flows for skb->dev different from napi->dev or I
miss something?)

Jarek P.
