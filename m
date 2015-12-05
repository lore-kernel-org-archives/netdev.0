From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb3: Convert simple_strtoul to kstrtox
Date: Sat, 05 Dec 2015 18:45:20 -0500 (EST)
Message-ID: <20151205.184520.1281826797997335875.davem@davemloft.net>
References: <1449239201-879-1-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: santosh@chelsio.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449239201-879-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: LABBE Corentin <clabbe.montjoie@gmail.com>
Date: Fri,  4 Dec 2015 15:26:40 +0100

> the simple_strtoul function is obsolete. This patch replace it by
> kstrtox.
> 
> Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>

Again, kstrtouint() provides a reasonable error code, therefore
when you do these conversions you should use that error code
rather than hardcoded -EWHATEVER.
