From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Patch net] macvlan: add NETIF_F_NETNS_LOCAL flag
Date: Mon, 10 Feb 2014 20:41:07 -0800
Message-ID: <CAHA+R7MhHuOPaT5oAF_S-a3u1_2mt=Vqd5HCdi9r3JV-fK-6Pw@mail.gmail.com>
References: <1392082593-7742-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140211014535.GA11150@order.stressinduktion.org>
	<CAHA+R7N2rxt5vyF+i8mi04dJaLk5bCgMAZOCexOLULLcQ-mT6w@mail.gmail.com>
	<20140211024009.GD11150@order.stressinduktion.org>
	<1392092120.6615.64.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:42099 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750869AbaBKElJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 23:41:09 -0500
Received: by mail-lb0-f177.google.com with SMTP id 10so3997806lbg.36
        for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 20:41:07 -0800 (PST)
In-Reply-To: <1392092120.6615.64.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 10, 2014 at 8:15 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2014-02-11 at 03:40 +0100, Hannes Frederic Sowa wrote:
>
>> Setting up a macvlan and moving it into another namespace without moving
>> the parent device is a nice feature. I am not an administrator, so I don't
>> use that stuff often, but given you can easily spawn namespaces and put
>> applications into them, one of the easiest things to connect those to
>> local network without routing over veth and such is the macvlan interface.
>
> Exactly.
>

Exactly broken by design.

IFA_LINK is an ifindex, ifindex is per-netns. macvlan should not use IFA_LINK.
