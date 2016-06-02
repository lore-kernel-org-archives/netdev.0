From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix potential infoleak in rds_inc_info_copy
Date: Wed, 01 Jun 2016 23:32:49 -0700 (PDT)
Message-ID: <20160601.233249.2145927586351299054.davem@davemloft.net>
References: <1464797476-26596-1-git-send-email-kjlu@gatech.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: santosh.shilimkar@oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, taesoo@gatech.edu,
	csong84@gatech.edu, kjlu@gatech.edu
To: kangjielu@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464797476-26596-1-git-send-email-kjlu@gatech.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kangjie Lu <kangjielu@gmail.com>
Date: Wed,  1 Jun 2016 12:11:16 -0400

> The last field "flags" of object "minfo" is not initialized.
> Copying this object out may leak kernel stack data.
> Assign 0 to it to avoid leak.
> 
> Signed-off-by: Kangjie Lu <kjlu@gatech.edu>

The correct subsystem prefix is "rds: ".  Please resubmit this patch
with your Subject corrected thusly.

Thanks.
