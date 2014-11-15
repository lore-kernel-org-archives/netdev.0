From: Vinson Lee <vlee@twopensource.com>
Subject: Re: tcp_mark_head_lost warning in Linux kernel 3.10
Date: Fri, 14 Nov 2014 17:48:47 -0800
Message-ID: <CAHTgTXWG5wF26V_w2K=3uxOPx=WCA7XZkpthy+cVSr+=+wW3CA@mail.gmail.com>
References: <CAHTgTXXqaVzVOyGuVWpdQokY8RmYRMriaLhBecLzfg=HF6V8dQ@mail.gmail.com>
	<1416006022.17262.77.camel@edumazet-glaptop2.roam.corp.google.com>
	<CADVnQymD96k6pBmkYHb5G5MAWcRywdgEb2jo-BnNttWeii0u2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Netdev <netdev@vger.kernel.org>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:42157 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755232AbaKOBsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 20:48:47 -0500
Received: by mail-qg0-f52.google.com with SMTP id a108so1291848qge.11
        for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 17:48:47 -0800 (PST)
In-Reply-To: <CADVnQymD96k6pBmkYHb5G5MAWcRywdgEb2jo-BnNttWeii0u2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 14, 2014 at 5:36 PM, Neal Cardwell <ncardwell@google.com> wrote:
> Thanks, Vinson. The theory I'm working on involves SACK reneging. What do
> you get from:
>
>   nstat -a -z | grep TcpExtTCPSACKReneging
>

$ nstat -a -z | grep TcpExtTCPSACKReneging
TcpExtTCPSACKReneging           184357             0.0
