From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][bpf-next] bpf: add missing break in for the
 TCP_BPF_SNDCWND_CLAMP case
Date: Wed, 05 Jul 2017 09:09:08 +0100 (WEST)
Message-ID: <20170705.090908.458530250899642598.davem@davemloft.net>
References: <20170704152112.18623-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@iogearbox.net, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170704152112.18623-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Tue,  4 Jul 2017 16:21:12 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> There appears to be a missing break in the TCP_BPF_SNDCWND_CLAMP case.
> Currently the non-error path where val is greater than zero falls through
> to the default case that sets the error return to -EINVAL. Add in
> the missing break.
> 
> Detected by CoverityScan, CID#1449376 ("Missing break in switch")
> 
> Fixes: 13bf96411ad2 ("bpf: Adds support for setting sndcwnd clamp")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
