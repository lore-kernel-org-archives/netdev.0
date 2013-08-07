From: wangweidong <wangweidong1@huawei.com>
Subject: [request for stable inclusion] tipc: fix lockdep warning during bearer
 initialization
Date: Wed, 7 Aug 2013 11:23:08 +0800
Message-ID: <5201BD9C.4070407@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <stable@vger.kernel.org>,
	<ying.xue@windriver.com>, <jon.maloy@ericsson.com>,
	<paul.gortmaker@windriver.com>, <dingtianhong@huawei.com>,
	Li Zefan <lizefan@huawei.com>
To: <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ying Xue, Jon, Paul or David,

4225a398c1352a7a5c14dc07277cb5cc4473983b
tipc: fix lockdep warning during bearer initialization

This looks applicable to stable-3.0/3.2/3.4, that fixed one deadlock. 
With the tipc-config cmd, I can reproduce that. The deadlock possibly
occur when the second TIPC bearer is registered, the deadlock can perhaps
really happen. And this patch works well. But git am or patch -p1 failed,
because a previous patch [commit 617d3c7a5 (tipc: compress out gratuitous
extra carriage returns)] deletes some blank lines. With some modifies, it
was built successful for me. What do you think?

And the bug was fixed in 3.7; The commit got its way into mainline in 3.7
cycle.

Thanks!
Wang Weidong
