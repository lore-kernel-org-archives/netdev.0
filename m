From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net] macvlan: add NETIF_F_NETNS_LOCAL flag
Date: Mon, 10 Feb 2014 20:15:20 -0800
Message-ID: <1392092120.6615.64.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1392082593-7742-1-git-send-email-xiyou.wangcong@gmail.com>
	 <20140211014535.GA11150@order.stressinduktion.org>
	 <CAHA+R7N2rxt5vyF+i8mi04dJaLk5bCgMAZOCexOLULLcQ-mT6w@mail.gmail.com>
	 <20140211024009.GD11150@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <cwang@twopensource.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:46430 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752211AbaBKEPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 23:15:22 -0500
Received: by mail-pd0-f179.google.com with SMTP id fp1so6575087pdb.24
        for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 20:15:21 -0800 (PST)
In-Reply-To: <20140211024009.GD11150@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-02-11 at 03:40 +0100, Hannes Frederic Sowa wrote:

> Setting up a macvlan and moving it into another namespace without moving
> the parent device is a nice feature. I am not an administrator, so I don't
> use that stuff often, but given you can easily spawn namespaces and put
> applications into them, one of the easiest things to connect those to
> local network without routing over veth and such is the macvlan interface.

Exactly.
