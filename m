From: Cong Wang <cwang@twopensource.com>
Subject: Re: Cannot move macvlan interface on top of bonding device
Date: Wed, 17 Sep 2014 09:46:52 -0700
Message-ID: <CAHA+R7O0LuvFujDnDjW-kcwG=9BGbaSBfO9GXhxD0ANLyeJLXQ@mail.gmail.com>
References: <CA+HUmGi74nx0zELqXX63nJCNXshTC9AkWoRG5bo6AMHyr_3+fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Weilong Chen <chenweilong@huawei.com>,
	Florian Westphal <fw@strlen.de>
To: Francesco Ruggeri <fruggeri@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:56461 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755891AbaIQQqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 12:46:54 -0400
Received: by mail-la0-f54.google.com with SMTP id ge10so2176286lab.41
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 09:46:53 -0700 (PDT)
In-Reply-To: <CA+HUmGi74nx0zELqXX63nJCNXshTC9AkWoRG5bo6AMHyr_3+fg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 17, 2014 at 8:56 AM, Francesco Ruggeri <fruggeri@arista.com> wrote:
> This used to work in older releases.
> The problem seems to be that commit f939981492 sets NETIF_F_NETNS_LOCAL
> on bonding interfaces, and commit 797f87f83 causes macvlan interfaces
> to inherit its features from the lower device.
>
> Is there a reason why NETIF_F_NETNS_LOCAL should be inherited from the
> lower device
> by macvlan interfaces?

commit 797f87f83 looks wrong, it should not inherit NETIF_F_NETNS_LOCAL,
so just clear this flag. Please submit a patch.
