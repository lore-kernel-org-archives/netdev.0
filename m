From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] calipso: fix resource leak on calipso_genopt failure
Date: Sat, 13 Aug 2016 14:56:41 -0700 (PDT)
Message-ID: <20160813.145641.1944190186523562997.davem@davemloft.net>
References: <1470935842-13884-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470935842-13884-1-git-send-email-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Thu, 11 Aug 2016 18:17:22 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> Currently, if calipso_genopt fails then the error exit path
> does not free the ipv6_opt_hdr new causing a memory leak. Fix
> this by kfree'ing new on the error exit path.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied, thanks.
