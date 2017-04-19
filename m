From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net 1/2] net sched actions: fix access to uninitialized
 data
Date: Wed, 19 Apr 2017 11:02:58 +0200
Message-ID: <58F727C2.70100@iogearbox.net>
References: <20170418101322.27666-1-w.bumiller@proxmox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>
To: Wolfgang Bumiller <w.bumiller@proxmox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41736 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761394AbdDSJDF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 05:03:05 -0400
In-Reply-To: <20170418101322.27666-1-w.bumiller@proxmox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Wolfgang,

On 04/18/2017 12:13 PM, Wolfgang Bumiller wrote:
[...]

Since this patch goes to -net tree and is a bug fix, please
also add a proper analysis into the commit log instead of
just an empty commit message.

A Fixes tag to your bug fix would also be appropriate, so
that this helps tracking follow-ups to the original commit
that introduced the code. For this one, should be:

Fixes: 1045ba77a596 ("net sched actions: Add support for user cookies")

> Signed-off-by: Wolfgang Bumiller <w.bumiller@proxmox.com>
> Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

Thanks,
Daniel
