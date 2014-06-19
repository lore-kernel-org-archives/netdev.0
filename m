From: Cong Wang <cwang@twopensource.com>
Subject: Please backport dev_kfree_skb_any fixes for stable
Date: Thu, 19 Jun 2014 16:48:32 -0700
Message-ID: <CAHA+R7N80Q6sh6ZjMM9B0rOUUx1YuDfE3OQGD+Av6+t7gz+MSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:57885 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965771AbaFSXsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2014 19:48:33 -0400
Received: by mail-qg0-f54.google.com with SMTP id q107so2793504qgd.13
        for <netdev@vger.kernel.org>; Thu, 19 Jun 2014 16:48:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, David


Please consider to backport the following dev_kfree_skb_any
commits for stable. They fix some annoying warnings for us.

commit c9974ad4aeb36003860100221a594f3c0ccc3f78
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Tue Mar 11 14:20:26 2014 -0700

    gianfar: Carefully free skbs in functions called by netpoll.

commit d8ec2c02caa3515f35d6c33eedf529394c419298
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Tue Mar 11 14:19:50 2014 -0700

    benet: Call dev_kfree_skby_any instead of kfree_skb.

commit e81f44b66b456a7dcfbdeffeb355458cd6a58973
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Tue Mar 11 14:19:14 2014 -0700

    mlx4: Call dev_kfree_skby_any instead of dev_kfree_skb.

commit f7e79913a1d6a6139211ead3b03579b317d25a1f
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Tue Mar 11 14:18:42 2014 -0700

    ixgb: Call dev_kfree_skby_any instead of dev_kfree_skb.

commit 497a27b9e1bcf6dbaea7a466cfcd866927e1b431
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Tue Mar 11 14:18:14 2014 -0700

    tg3: Call dev_kfree_skby_any instead of dev_kfree_skb.

commit f458b2ee93ee3606c83f76213fbe49e026bac754
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Tue Mar 11 14:17:41 2014 -0700

    bnx2: Call dev_kfree_skby_any instead of dev_kfree_skb.

commit 2bb77ab42a6a40162a367b80394b96bb756ad5f1
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Tue Mar 11 14:16:58 2014 -0700

    bonding: Call dev_kfree_skby_any instead of kfree_skb.

commit 989c9ba104d9ce53c1ca918262f3fdfb33aca12a
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Tue Mar 11 14:16:14 2014 -0700

    r8169: Call dev_kfree_skby_any instead of dev_kfree_skb.

commit a2ccd2e4bd70122523a7bf21cec4dd6e34427089
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Tue Mar 11 14:15:36 2014 -0700

    8139too: Call dev_kfree_skby_any instead of dev_kfree_skb.

commit 508f81d517ed1f3f0197df63ea7ab5cd91b6f3b3
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Tue Mar 11 14:14:58 2014 -0700

    8139cp: Call dev_kfree_skby_any instead of kfree_skb.



Thanks!
