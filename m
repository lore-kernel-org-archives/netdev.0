From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] net: relax PKTINFO non local ipv6 udp xmit check
Date: Tue, 30 Aug 2011 11:51:40 -0700
Message-ID: <CANP3RGcA-=uiTtCcgDnZx-Afoo15Qzktz42Zvs==+R+2Fr-avQ@mail.gmail.com>
References: <20110828.171154.1746224796788156557.davem@davemloft.net>
	<1314570931-6233-1-git-send-email-zenczykowski@gmail.com>
	<20110828.210633.783157755808327582.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:40113 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755789Ab1H3Svo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 14:51:44 -0400
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p7UIpgSJ021115
	for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 11:51:42 -0700
Received: from gxk19 (gxk19.prod.google.com [10.202.11.19])
	by hpaq11.eem.corp.google.com with ESMTP id p7UIpes0022725
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 11:51:41 -0700
Received: by gxk19 with SMTP id 19so5340347gxk.3
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 11:51:40 -0700 (PDT)
In-Reply-To: <20110828.210633.783157755808327582.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 28, 2011 at 6:06 PM, David Miller <davem@davemloft.net> wrote:
> > Allow transparent sockets to be less restrictive about
> > the source ip of ipv6 udp packets being sent.
>
> Applied, thanks a lot.

FYI, I don't see this in either git repository:

http://git.kernel.org/?p=linux/kernel/git/davem/net.git;a=shortlog
http://git.kernel.org/?p=linux/kernel/git/davem/net-next.git;a=shortlog

I'd expect it to have shown up in net-next by now.

I'm also curious whether anyone knows of any good reason why
transparent sockets require CAP_NET_ADMIN instead of CAP_NET_RAW (or
either one of CAP_NET_{RAW|ADMIN}).

Maciej
