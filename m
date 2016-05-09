From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tools: bpf_jit_disasm: check for klogctl failure
Date: Sun, 08 May 2016 23:33:31 -0400 (EDT)
Message-ID: <20160508.233331.1216073258499869420.davem@davemloft.net>
References: <1462487973-21712-1-git-send-email-colin.king@canonical.com>
	<572BCD60.1000804@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: colin.king@canonical.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <572BCD60.1000804@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri, 06 May 2016 00:46:56 +0200

> On 05/06/2016 12:39 AM, Colin King wrote:
>> From: Colin Ian King <colin.king@canonical.com>
>>
>> klogctl can fail and return -ve len, so check for this and
>> return NULL to avoid passing a (size_t)-1 to malloc.
>>
>> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> 
> [ would be nice to get Cc'ed in future ... ]
> 
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Applied.
