From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: rds: use correct size for max unacked packets and
 bytes
Date: Wed, 04 Feb 2015 16:08:17 -0800 (PST)
Message-ID: <20150204.160817.1551916015584303515.davem@davemloft.net>
References: <1422971760-8217-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, chien.yen@oracle.com,
	rds-devel@oss.oracle.com, netdev@vger.kernel.org
To: sasha.levin@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422971760-8217-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sasha Levin <sasha.levin@oracle.com>
Date: Tue,  3 Feb 2015 08:55:58 -0500

> Max unacked packets/bytes is an int while sizeof(long) was used in the
> sysctl table.
> 
> This means that when they were getting read we'd also leak kernel memory
> to userspace along with the timeout values.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Applied, thanks.
