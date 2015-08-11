From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next] bpf: s390: Fix build error caused by the
 struct bpf_array member name changed
Date: Tue, 11 Aug 2015 10:24:17 +0200
Message-ID: <55C9B131.50108@iogearbox.net>
References: <1439276026-60789-1-git-send-email-xiakaixu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	wangnan0@huawei.com, Michael Holzheu <holzheu@linux.vnet.ibm.com>
To: Kaixu Xia <xiakaixu@huawei.com>, fengguang.wu@intel.com,
	davem@davemloft.net, ast@plumgrid.com, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439276026-60789-1-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/11/2015 08:53 AM, Kaixu Xia wrote:
> There is a build error that "'struct bpf_array' has no member
> named 'prog'" on s390. In commit 2a36f0b, the member 'prog' of
> struct bpf_array is replaced by 'ptrs'. So this patch fixes it.
>
> Signed-off-by: Kaixu Xia <xiakaixu@huawei.com>

You were also asked to add a proper Fixes tag :

Fixes: 2a36f0b92eb6 ("bpf: Make the bpf_prog_array_map more generic")

I guess this bug was reported by Fengguang as you have him in Cc ?

If that should be the case, then please also add a "Reported-by:" tag
for his bug report.

Code looks good to me.
