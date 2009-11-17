From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: [PATCH 1/5]net: PPP buffer too small for higher speed
	connections
Date: Tue, 17 Nov 2009 12:21:02 -0500
Message-ID: <20091117172102.GH15159@caffeine.csclub.uwaterloo.ca>
References: <fb8cc3511cffa.1cffafb8cc351@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, william.allen.simpson@gmail.com,
	jarkao2@gmail.com
To: fangxiaozhi 00110321 <huananhu@huawei.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756090AbZKQRU5@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <fb8cc3511cffa.1cffafb8cc351@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 17, 2009 at 07:59:05PM +0800, fangxiaozhi 00110321 wrote:
> From: fangxiaozhi <huananhu@huawei.com>
> 1. This patch is based on the kernel of 2.6.32-rc7 
> 2. In this patch, we enlarge the out buffer size to optimize the upload speed for the ppp connection. Then it can support the upload of HSUPA data cards.
> Signed-off-by: fangxiaozhi <huananhu@huawei.com>
> -----------------------------------------------------------------------------------------
> --- a/drivers/net/ppp_async.c	2009-10-12 05:43:56.000000000 +0800
> +++ b/drivers/net/ppp_async.c	2009-10-15 16:29:56.000000000 +0800
> @@ -36,7 +36,7 @@
>  
>  #define PPP_VERSION	"2.4.2"
>  
> -#define OBUFSIZE	256
> +#define OBUFSIZE	4096
>  
>  /* Structure for storing local state. */
>  struct asyncppp {

I don't know what an HSUPA connection is, so what kind of speed is that?
I am just wondering if this would affect ppp on other connections that
are async (in a positive manner that is).

-- 
Len Sorensen
