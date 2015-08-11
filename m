From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] bpf: s390: Fix build error caused by the
 struct bpf_array member name changed
Date: Tue, 11 Aug 2015 11:49:54 -0700 (PDT)
Message-ID: <20150811.114954.2113934998531402950.davem@davemloft.net>
References: <1439283411-163308-1-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, fengguang.wu@intel.com, ast@plumgrid.com,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	wangnan0@huawei.com
To: xiakaixu@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439283411-163308-1-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kaixu Xia <xiakaixu@huawei.com>
Date: Tue, 11 Aug 2015 08:56:51 +0000

> There is a build error that "'struct bpf_array' has no member
> named 'prog'" on s390. In commit 2a36f0b92eb6 ("bpf: Make the
> bpf_prog_array_map more generic"), the member 'prog' of struct
> bpf_array is replaced by 'ptrs'. So this patch fixes it.
> 
> Fixes: 2a36f0b92eb6 ("bpf: Make the bpf_prog_array_map more generic")
> Reported-by: Wu Fengguang <fengguang.wu@intel.com>
> Signed-off-by: Kaixu Xia <xiakaixu@huawei.com>

Applied, thanks.
