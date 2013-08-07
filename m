From: wangweidong <wangweidong1@huawei.com>
Subject: [request for stable inclusion] net: neighbour: prohibit negative
 value for unres_qlen_bytes parameter
Date: Wed, 7 Aug 2013 11:23:00 +0800
Message-ID: <5201BD94.4060100@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <stable@vger.kernel.org>,
	<davidshan@tencent.com>, <dingtianhong@huawei.com>,
	Li Zefan <lizefan@huawei.com>
To: <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Shan Wei or David,

ce46cc64d47a8afaf13c300b09a7f9c29f4979b6
net: neighbour: prohibit negative value for unres_qlen_bytes parameter

This looks applicable to stable-3.4, I can reproduce it on this 3.4 kernel.
It fixes a type overflow when setting unres_qlen. I try to reproduce, and
then this patch works well. But git am or patch -p1 failed, because a
previous patch [commit 9a6308d74ed (neighbour: Stop using NLA_PUT*().)]
change the NLA_PUT_U32 to nla_put_u32. With some modifies, it was built
successful for me. What do you think?

stable-3.0 and stable-3.2 are free from this bug. And the bug was fixed in
3.8; The commit got its way into mainline in 3.8 cycle.

Thanks!
Wang Weidong
