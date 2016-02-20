From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] net: use skb_postpush_rcsum instead of own
 implementations
Date: Fri, 19 Feb 2016 18:13:09 -0800
Message-ID: <20160220021308.GA2620@ast-mbp.thefacebook.com>
References: <bb805bd677f8ba6f5c40b485ed41009d3fef1f3d.1455924108.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, hannes@stressinduktion.org, jesse@kernel.org,
	ast@kernel.org, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34929 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1428310AbcBTCNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 21:13:13 -0500
Received: by mail-pa0-f49.google.com with SMTP id ho8so60998679pac.2
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2016 18:13:13 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <bb805bd677f8ba6f5c40b485ed41009d3fef1f3d.1455924108.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 20, 2016 at 12:29:30AM +0100, Daniel Borkmann wrote:
> Replace individual implementations with the recently introduced
> skb_postpush_rcsum() helper.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

nice follow up to f8ffad69c9f8 indeed.
Acked-by: Alexei Starovoitov <ast@kernel.org>
