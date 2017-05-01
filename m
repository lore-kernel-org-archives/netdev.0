From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] qed: Unlock on error in qed_vf_pf_acquire()
Date: Sun, 30 Apr 2017 22:42:48 -0400 (EDT)
Message-ID: <20170430.224248.763979997313093994.davem@davemloft.net>
References: <20170428125608.djln5r7h4d53it5s@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@cavium.com, Ariel.Elior@cavium.com,
        everest-linux-l2@cavium.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170428125608.djln5r7h4d53it5s@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 28 Apr 2017 15:56:09 +0300

> My static checker complains that we're holding a mutex on this error
> path.  Let's goto exit instead of returning directly.
> 
> Fixes: b0bccb69eba3 ("qed: Change locking scheme for VF channel")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
