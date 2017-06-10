From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] i40evf: remove redundant null check on key
Date: Sat, 10 Jun 2017 14:33:42 +0300
Message-ID: <20170610113342.f4v5j3inpoxwqkhf@mwanda>
References: <20170606235407.6478-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170606235407.6478-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch isn't right...

On Wed, Jun 07, 2017 at 12:54:07AM +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> key has previously been null checked so the subsequent null check
> is redundant as key can never be null at that point, so remove it.
> 

Actually, it's the reverse.  "key" is always NULL.  Probably the ||
should be a &&?

regards,
dan carpenter
