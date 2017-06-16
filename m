From: Serhey Popovych <serhe.popovych@gmail.com>
Subject: Re: [PATCH 1/3] dev: Prevent creating network devices with negative ifindex
Date: Fri, 16 Jun 2017 21:14:01 +0300
Message-ID: <CAGCP4zM90OY=D76jok6TK_KYR60FF5B5EYUfxDerGsg_h1wC6g@mail.gmail.com>
References: <cover.1497621810.git.serhe.popovych@gmail.com>
 <d365b6f06598d041a177b91b15929285c2649935.1497621810.git.serhe.popovych@gmail.com>
 <20170616091806.2dd229e2@xeon-e3> <02a31165-ad2f-fcdf-e7c5-f66a35712d4e@gmail.com>
 <20170616102542.691385b9@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f181.google.com ([209.85.128.181]:34828 "EHLO
        mail-wr0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753241AbdFPSPH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 14:15:07 -0400
Received: by mail-wr0-f181.google.com with SMTP id y25so3292166wrd.2
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 11:15:06 -0700 (PDT)
In-Reply-To: <20170616102542.691385b9@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> What do you think?
>
> Passing -1 is an error, it doesn't make sense  to try and be
> helpful to buggy userland.

Here is commit I actually change/fix:

commit 9c7dafbfab15 ("net: Allow to create links with given ifindex")

In this change done the opposite: check for ifm->ifi_index moved to
register_netdevice() from rtnl_newlink().

Let me understand finally: why do I need to reverse and move check
for dev->ifindex from register_netdevice() to rtnl_newlink()? That
will partially revert commit I note above.

-- 
Thanks,  Serhey
