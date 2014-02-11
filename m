From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net] macvlan: add NETIF_F_NETNS_LOCAL flag
Date: Mon, 10 Feb 2014 20:14:17 -0800
Message-ID: <1392092057.6615.63.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1392082593-7742-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:46500 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752180AbaBKEOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 23:14:20 -0500
Received: by mail-pd0-f170.google.com with SMTP id p10so7047852pdj.1
        for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 20:14:19 -0800 (PST)
In-Reply-To: <1392082593-7742-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-02-10 at 17:36 -0800, Cong Wang wrote:
> From: Cong Wang <cwang@twopensource.com>
> 
> BZ: https://bugzilla.kernel.org/show_bug.cgi?id=66691
> 
> There is no point to allow moving a macvlan device to
> another namespace while the lower device is still in
> this namespace. tunnels already set this flag.

What do you mean ?

This is probably one of the needed/useful feature of macvlan !
