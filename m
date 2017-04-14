From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: drop non loopback packets claiming to originate
 from ::1
Date: Fri, 14 Apr 2017 23:44:15 +0200
Message-ID: <1492206255.3019658.945047304.6C50854A@webmail.messagingengine.com>
References: <20170414182243.24506-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:41255 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751962AbdDNVoQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 17:44:16 -0400
In-Reply-To: <20170414182243.24506-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 14, 2017, at 20:22, Florian Westphal wrote:
> We lack a saddr check for ::1. This causes security issues e.g. with acls
> permitting connections from ::1 because of assumption that these
> originate
> from local machine.
> 
> Assuming a source address of ::1 is local seems reasonable.
> RFC4291 doesn't allow such a source address either, so drop such packets.
> 
> Reported-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks!
