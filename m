From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net v2] l2tp: fix race condition in l2tp_tunnel_delete
Date: Tue, 26 Sep 2017 15:59:19 +0200
Message-ID: <20170926135919.GA6961@bistromath.localdomain>
References: <6bfc5aceda47773af4c75fe7e0e3c0d255a2342d.1505828155.git.sd@queasysnail.net>
 <20170919164337.zn3p6ikwsgnw7ba6@alphalink.fr>
 <20170922161624.GA31500@bistromath.localdomain>
 <20170925123355.a6qof4ovgr6ksx3s@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, Xin Long <lucien.xin@gmail.com>,
        Tom Parkin <tparkin@katalix.com>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44620 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935805AbdIZN7Y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 09:59:24 -0400
Content-Disposition: inline
In-Reply-To: <20170925123355.a6qof4ovgr6ksx3s@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-09-25, 14:33:55 +0200, Guillaume Nault wrote:
[...]
> So what about using your v2 patch, but without the ->dead flag test in
> l2tp_tunnel_get() and l2tp_tunnel_find*()?

Ok, I think that's reasonable. I'll post a v3, thanks.

-- 
Sabrina
