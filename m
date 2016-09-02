From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [Patch net-next 1/2] vxlan: call peernet2id() in fdb notification
Date: Fri, 2 Sep 2016 10:59:14 +0200
Message-ID: <7302a881-d172-84af-5da0-e9b9dd7ceab3@6wind.com>
References: <1472792025-14702-1-git-send-email-xiyou.wangcong@gmail.com>
 <1472792025-14702-2-git-send-email-xiyou.wangcong@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:36475 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752706AbcIBI7R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 04:59:17 -0400
Received: by mail-wm0-f42.google.com with SMTP id c133so19279468wmd.1
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 01:59:16 -0700 (PDT)
In-Reply-To: <1472792025-14702-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/09/2016 à 06:53, Cong Wang a écrit :
> netns id should be already allocated each time we change
> netns, that is, in dev_change_net_namespace() (more precisely
> in rtnl_fill_ifinfo()). It is safe to just call peernet2id() here.
> 
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
