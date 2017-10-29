From: David Miller <davem@davemloft.net>
Subject: Re: Linux 4.14-rc6 bisected regression tun devices not working
 anymore in openvpn
Date: Sun, 29 Oct 2017 10:42:12 +0900 (KST)
Message-ID: <20171029.104212.699903120729091374.davem@davemloft.net>
References: <ac1aaeab-b9f5-a034-56a8-4305494db468@eikelenboom.it>
        <CAM_iQpWfgp3R+Qx59hTcVYuSsPnNWvoDC9=ofkghVM4gguPLzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@eikelenboom.it, torvalds@linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43168 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751216AbdJ2BmT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 21:42:19 -0400
In-Reply-To: <CAM_iQpWfgp3R+Qx59hTcVYuSsPnNWvoDC9=ofkghVM4gguPLzw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Sat, 28 Oct 2017 10:37:27 -0700

> On Sat, Oct 28, 2017 at 7:57 AM, Sander Eikelenboom
> <linux@eikelenboom.it> wrote:
>> The offending commit is:
>>     0ad646c81b2182f7fa67ec0c8c825e0ee165696d
>>     "tun: call dev_get_valid_name() before register_netdevice()"
>>
>> Reverting this commit fixes the issue for me, it's unfortunate that the commit it self seems to fix an other issue.
> 
> It should be fixed by:
> 
> commit 5c25f65fd1e42685f7ccd80e0621829c105785d9
> Author: Julien Gomes <julien@arista.com>
> Date:   Wed Oct 25 11:50:50 2017 -0700
> 
>     tun: allow positive return values on dev_get_valid_name() call

I made sure to queue this up for -stable since the offending commit is queued up
there as well.
