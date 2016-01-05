From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] net: sched: fix missing free per cpu on qstats
Date: Tue, 05 Jan 2016 19:00:02 +0100
Message-ID: <568C04A2.7020804@iogearbox.net>
References: <20160105171136.9063.98710.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50576 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751906AbcAESAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 13:00:05 -0500
In-Reply-To: <20160105171136.9063.98710.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/05/2016 06:11 PM, John Fastabend wrote:
> When a qdisc is using per cpu stats (currently just the ingress
> qdisc) only the bstats are being freed. This also free's the qstats.
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
