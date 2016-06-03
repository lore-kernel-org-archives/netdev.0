From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rds: fix an infoleak in rds_inc_info_copy
Date: Thu, 02 Jun 2016 21:33:03 -0700 (PDT)
Message-ID: <20160602.213303.2184174899734544902.davem@davemloft.net>
References: <1464855080-29671-1-git-send-email-kjlu@gatech.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: santosh.shilimkar@oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, taesoo@gatech.edu,
	csong84@gatech.edu, kjlu@gatech.edu
To: kangjielu@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464855080-29671-1-git-send-email-kjlu@gatech.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kangjie Lu <kangjielu@gmail.com>
Date: Thu,  2 Jun 2016 04:11:20 -0400

> The last field "flags" of object "minfo" is not initialized.
> Copying this object out may leak kernel stack data.
> Assign 0 to it to avoid leak.
> 
> Signed-off-by: Kangjie Lu <kjlu@gatech.edu>

Applied.
