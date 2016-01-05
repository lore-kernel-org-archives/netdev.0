From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: sched: fix missing free per cpu on qstats
Date: Tue, 05 Jan 2016 09:44:11 -0800
Message-ID: <1452015851.8255.108.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20160105171136.9063.98710.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, daniel@iogearbox.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:36000 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751688AbcAERoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 12:44:13 -0500
Received: by mail-pf0-f177.google.com with SMTP id 65so178556743pff.3
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 09:44:13 -0800 (PST)
In-Reply-To: <20160105171136.9063.98710.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-01-05 at 09:11 -0800, John Fastabend wrote:
> When a qdisc is using per cpu stats (currently just the ingress
> qdisc) only the bstats are being freed. This also free's the qstats.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

David, please add the following tag to ease backports to stable kernels:

Fixes: 22e0f8b9322cb ("net: sched: make bstats per cpu and estimator RCU safe")

Thanks !
