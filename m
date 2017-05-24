From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: rtnetlink: bail out from rtnl_fdb_dump() on parse
 error
Date: Wed, 24 May 2017 15:32:24 -0400 (EDT)
Message-ID: <20170524.153224.1230164587077679673.davem@davemloft.net>
References: <20170523112028.132630-1-glider@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: glider@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170523112028.132630-1-glider@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Potapenko <glider@google.com>
Date: Tue, 23 May 2017 13:20:28 +0200

> rtnl_fdb_dump() failed to check the result of nlmsg_parse(), which led
> to contents of |ifm| being uninitialized because nlh->nlmsglen was too
> small to accommodate |ifm|. The uninitialized data may affect some
> branches and result in unwanted effects, although kernel data doesn't
> seem to leak to the userspace directly.
> 
> The bug has been detected with KMSAN and syzkaller.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>

Applied, thanks.
