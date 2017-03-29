From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH net] l2tp: purge socket queues in the .destruct() callback
Date: Wed, 29 Mar 2017 08:37:25 +0200
Message-ID: <20170329063725.hyr2bq4ux63ea7iw@alphalink.fr>
References: <5e9e60582739bc2b9def6c29abe071913632878a.1490707863.git.g.nault@alphalink.fr>
 <5d7b420189448fbc837a115b34ba59e42781aaef.1490707863.git.g.nault@alphalink.fr>
 <20170328.213950.605445824406263363.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:51341 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753397AbdC2Ghe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 02:37:34 -0400
Content-Disposition: inline
In-Reply-To: <20170328.213950.605445824406263363.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 28, 2017 at 09:39:50PM -0700, David Miller wrote:
> As a quick guess, I'm thinking this problem might have been introduced
> by:
> 
> ====================
> commit 9e9cb6221aa7cb04765484fe87cc2d1b92edce64
> Author: Guillaume Nault <g.nault@alphalink.fr>
> Date:   Thu Mar 6 11:15:10 2014 +0100
> 
>     l2tp: fix userspace reception on plain L2TP sockets
> ====================
> 
True. Will resubmit.
