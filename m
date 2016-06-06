From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] gtp: #define _UAPI_LINUX_GTP_H_ and not
 _UAPI_LINUX_GTP_H__
Date: Mon, 6 Jun 2016 16:58:32 +0200
Message-ID: <20160606145832.GA1502@salvia>
References: <1465217500-13945-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1465217500-13945-1-git-send-email-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 06, 2016 at 01:51:40PM +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> Fix clang build warning:
> 
> ./include/uapi/linux/gtp.h:1:9: warning: '_UAPI_LINUX_GTP_H_' is
> used as a header guard here, followed by #define of a different
> macro [-Wheader-guard]
> 
> fix by defining  _UAPI_LINUX_GTP_H_ and not _UAPI_LINUX_GTP_H__
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>

I don't see this in netdev's patchwork:

        http://patchwork.ozlabs.org/project/netdev/list/

So please, resubmit Cc'ing netdev@vger.kernel.org.

Thanks.
