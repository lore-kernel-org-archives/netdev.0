From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] netem: Fixes byte backlog accounting for the first of two
 chained netem instances
Date: Sat, 4 Apr 2015 00:21:16 +0200
Message-ID: <CAPh34mdKV972Y7=BtddayCq3_PDZqYTXOq8eQk7SGZiQrbFvLQ@mail.gmail.com>
References: <DM2PR01MB511AE74EFA517D7A30CD41DD1F10@DM2PR01MB511.prod.exchangelabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "stephen@networkplumber.org" <stephen@networkplumber.org>,
	"netem@lists.linux-foundation.org" <netem@lists.linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Beshay, Joseph" <jdb109120@utdallas.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:34342 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752133AbbDCWVS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 18:21:18 -0400
Received: by lboc7 with SMTP id c7so85754129lbo.1
        for <netdev@vger.kernel.org>; Fri, 03 Apr 2015 15:21:16 -0700 (PDT)
In-Reply-To: <DM2PR01MB511AE74EFA517D7A30CD41DD1F10@DM2PR01MB511.prod.exchangelabs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3 April 2015 at 23:52, Beshay, Joseph <jdb109120@utdallas.edu> wrote:

> +                       /* jbeshay: update byte backlog */
> +                       qdisc_qstats_backlog_dec(sch, skb);

Patch seems fine to me. Except the comment: that you update the qstat
backlog is already noted in the function name - superfluous comment.
That *you* fixed it will be saved in git. Think about it if we add
these kinds of comments all over the place ...

Acked-by: Hagen Paul Pfeifer <hagen@jauu.net>
