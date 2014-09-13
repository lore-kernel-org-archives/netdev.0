From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] ipv6: exit early in addrconf_notify() if IPv6 is disabled
Date: Fri, 12 Sep 2014 17:10:32 -0700
Message-ID: <CAM_iQpXSX4q9ZPCXrqZpCFXLduzvXgx_AgFsgHCR8wj00R8PUA@mail.gmail.com>
References: <1410473236-3346-1-git-send-email-xiyou.wangcong@gmail.com>
	<1410553099.2970.18.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>
To: Hannes Frederic Sowa <hannes@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f44.google.com ([209.85.219.44]:43835 "EHLO
	mail-oa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751773AbaIMAKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 20:10:33 -0400
Received: by mail-oa0-f44.google.com with SMTP id o6so1161540oag.17
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 17:10:32 -0700 (PDT)
In-Reply-To: <1410553099.2970.18.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 12, 2014 at 1:18 PM, Hannes Frederic Sowa <hannes@redhat.com> wrote:
>
> disable_ipv6 is absolutely bad implemented. It should not be in the ipv6
> procfs namespace at all. An inet6_dev must be available to manage this
> knob! Thus we are automagically subscribed to all ipv6 LL multicast
> groups.


Exactly, this is chicken and egg problem and is why we have ipv6_idev_add()
in the NETDEV_REGISTER event.
