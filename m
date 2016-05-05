From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] tools: bpf_jit_disasm: check for klogctl failure
Date: Fri, 06 May 2016 00:46:56 +0200
Message-ID: <572BCD60.1000804@iogearbox.net>
References: <1462487973-21712-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>,
	"David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462487973-21712-1-git-send-email-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/06/2016 12:39 AM, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
>
> klogctl can fail and return -ve len, so check for this and
> return NULL to avoid passing a (size_t)-1 to malloc.
>
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

[ would be nice to get Cc'ed in future ... ]

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
