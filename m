From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net 9/9] net/mlx5e: Reset link modes upon setting speed to zero
Date: Thu, 21 Apr 2016 22:01:18 +0300
Message-ID: <CALzJLG9ZbuwmGvuU5t68fYuErCUXU4c7_cf3n7O397EM06sWJg@mail.gmail.com>
References: <1461069222-27076-1-git-send-email-saeedm@mellanox.com>
 <1461069222-27076-10-git-send-email-saeedm@mellanox.com> <20160421.140454.143155848960923980.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:33706 "EHLO
	mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240AbcDUTCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 15:02:04 -0400
Received: by mail-yw0-f194.google.com with SMTP id o63so12314170ywe.0
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2016 12:01:38 -0700 (PDT)
In-Reply-To: <20160421.140454.143155848960923980.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 21, 2016 at 9:04 PM, David Miller <davem@davemloft.net> wrote:
> From: Saeed Mahameed <saeedm@mellanox.com>
> Date: Tue, 19 Apr 2016 15:33:42 +0300
>
>> Upon ethtool request to set speed to 0 we handle it as a special request
>> to reset link modes to Device's defaults.
>>
>> Fixes: f62b8bb8f2d3 ("net/mlx5: Extend mlx5_core to support ConnectX-4
>> Ethernet functionality")
>> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
>
> Please don't try to sneak things like this into the patches you submit.
>

No one is trying to sneak things here, This patch is transparent
enough and well documented, it is not fair to call it "sneaking" !

I am glad this is what you think about the patch, but i am a little
bit stunned of what you think about me .

> If you continue to add weird stuff like this, I will never _ever_ be
> able to trust you guys and have a high degree of confidence in your
> changes.  If you continue like this, I will always have to audit your
> patches very strictly which is very time consuming for me.
>

Well i wanted to argue on why i think it is ok to treat speed=0 as
special reset request, but I also kinda  agree with you on this, I
won't waste more of your time on this.

I hope I won't disappoint you in the future, after all we learn from the best.

> Do not extend ethtool's semantics in a way which suits you specifically.
>
> If we want to have this semantic, you must first propose it as a
> global semantic which then in turn can be adopted by all drivers
> supporting ethtool.
>

Sure thing, will drop this patch now, and will improve it later.

Thank you.
