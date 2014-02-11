From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net] macvlan: add NETIF_F_NETNS_LOCAL flag
Date: Mon, 10 Feb 2014 21:21:27 -0800
Message-ID: <1392096087.6615.72.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1392082593-7742-1-git-send-email-xiyou.wangcong@gmail.com>
	 <20140211014535.GA11150@order.stressinduktion.org>
	 <CAHA+R7N2rxt5vyF+i8mi04dJaLk5bCgMAZOCexOLULLcQ-mT6w@mail.gmail.com>
	 <20140211024009.GD11150@order.stressinduktion.org>
	 <1392092120.6615.64.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7MhHuOPaT5oAF_S-a3u1_2mt=Vqd5HCdi9r3JV-fK-6Pw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:58400 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721AbaBKFVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 00:21:32 -0500
Received: by mail-pa0-f49.google.com with SMTP id hz1so7142368pad.22
        for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 21:21:31 -0800 (PST)
In-Reply-To: <CAHA+R7MhHuOPaT5oAF_S-a3u1_2mt=Vqd5HCdi9r3JV-fK-6Pw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-02-10 at 20:41 -0800, Cong Wang wrote:

> Exactly broken by design.

Design of what ? Do you have a pointer to a document about this
'design' ?

> 
> IFA_LINK is an ifindex, ifindex is per-netns. macvlan should not use IFA_LINK.

When this was 'designed', ifindex were not per netns.

Apparently nobody spotted this when ifindexes become per netns.

I am sure we can find a solution, keeping this very useful
functionality.

BTW, are Cong Wang <cwang@twopensource.com> and Cong Wang
<xiyou.wangcong@gmail.com> different persons ?
