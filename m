From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: fix the bug "'struct bpf_array' has no
 member named 'prog'" in s390 architecture
Date: Mon, 10 Aug 2015 22:35:42 -0700 (PDT)
Message-ID: <20150810.223542.2033645138701106691.davem@davemloft.net>
References: <1439269224-13266-1-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, ast@plumgrid.com, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, wangnan0@huawei.com
To: xiakaixu@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439269224-13266-1-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kaixu Xia <xiakaixu@huawei.com>
Date: Tue, 11 Aug 2015 05:00:24 +0000

> 'Kbuild test robot' sent me an email about a build error
> "'struct bpf_array' has no member named 'prog'" in s390
> architecture. This error is caused by commit: 2a36f0b92eb
> 638dd023870574eb471b1c56be9ad [656/692] bpf: Make the bpf
> _prog_array_map more generic. In this patch, the member 'prog'
> of struct bpf_array has been replaced by 'ptrs'. So this
> patch fix it.

Please resubmit with a proper "Fixes: " and "Signed-off-by: "
tags.
