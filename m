From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH net] l2tp: hold tunnel socket when handling control
 frames in l2tp_ip and l2tp_ip6
Date: Wed, 29 Mar 2017 08:36:27 +0200
Message-ID: <20170329063627.v3bnpoekjkqmsebt@alphalink.fr>
References: <5e9e60582739bc2b9def6c29abe071913632878a.1490707863.git.g.nault@alphalink.fr>
 <20170328.213416.449917447965488852.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:51227 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753286AbdC2Ggb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 02:36:31 -0400
Content-Disposition: inline
In-Reply-To: <20170328.213416.449917447965488852.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 28, 2017 at 09:34:16PM -0700, David Miller wrote:
> You introduced this bug in commit:
> 
> ====================
> commit a3c18422a4b4e108bcf6a2328f48867e1003fd95
> Author: Guillaume Nault <g.nault@alphalink.fr>
> Date:   Tue Nov 29 13:09:45 2016 +0100
> 
>     l2tp: hold socket before dropping lock in l2tp_ip{, 6}_recv()
> ====================
> 
> Therefore you should make this clear with a proper "Fixes: " tag
> such as:
> 
> Fixes: a3c18422a4b4 ("l2tp: hold socket before dropping lock in l2tp_ip{, 6}_recv()")
> 
> on a line right before your signoff.

Indeed, I should have realised that earlier, sorry. I'll resubmit.
