From: Neal Cardwell <ncardwell@google.com>
Subject: Re: tcp_mark_head_lost warning in Linux kernel 3.10
Date: Fri, 14 Nov 2014 21:08:22 -0500
Message-ID: <CADVnQy=nOcAwOoJFfG_4=wjJCESrJpnE3YHNLOYhmX+yskhC8g@mail.gmail.com>
References: <CAHTgTXXqaVzVOyGuVWpdQokY8RmYRMriaLhBecLzfg=HF6V8dQ@mail.gmail.com>
	<1416006022.17262.77.camel@edumazet-glaptop2.roam.corp.google.com>
	<CADVnQymD96k6pBmkYHb5G5MAWcRywdgEb2jo-BnNttWeii0u2Q@mail.gmail.com>
	<CAHTgTXWG5wF26V_w2K=3uxOPx=WCA7XZkpthy+cVSr+=+wW3CA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Netdev <netdev@vger.kernel.org>
To: Vinson Lee <vlee@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f176.google.com ([209.85.216.176]:39184 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751619AbaKOCIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 21:08:22 -0500
Received: by mail-qc0-f176.google.com with SMTP id x3so13838630qcv.35
        for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 18:08:22 -0800 (PST)
In-Reply-To: <CAHTgTXWG5wF26V_w2K=3uxOPx=WCA7XZkpthy+cVSr+=+wW3CA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 14, 2014 at 8:48 PM, Vinson Lee <vlee@twopensource.com> wrote:
>
> On Fri, Nov 14, 2014 at 5:36 PM, Neal Cardwell <ncardwell@google.com> wrote:
> > Thanks, Vinson. The theory I'm working on involves SACK reneging. What do
> > you get from:
> >
> >   nstat -a -z | grep TcpExtTCPSACKReneging
> >
>
> $ nstat -a -z | grep TcpExtTCPSACKReneging
> TcpExtTCPSACKReneging           184357             0.0

OK, good. So that is at least consistent with the theory. Thanks!

neal
