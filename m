From: Dan Carpenter <error27@gmail.com>
Subject: Re: [patch] iwl: cleanup: remove unneeded error handling
Date: Thu, 29 Apr 2010 11:29:57 +0200
Message-ID: <20100429092956.GH29093@bicker>
References: <20100428090115.GF29093@bicker> <1272507134.14773.4339.camel@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Ortiz, Samuel" <samuel.ortiz@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1272507134.14773.4339.camel@debian>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 29, 2010 at 10:12:14AM +0800, Zhu Yi wrote:
> 
> Thanks. But looks like you missed the one in if_sdio_debugfs_init().
> 

Yup.

> I don't think we even need to check -ENODEV ourselves because if
> DEBUG_FS is not compiled in, all the debugfs utility functions will
> become no-op.
> 

Good point.

> Signed-off-by: Dan Carpenter <error27@gmail.com>

Probably this could get changed to just "Reported-by" but I'm happy to
take credit for other peoples work.  :)

> Signed-off-by: Zhu Yi <yi.zhu@intel.com>
> 

Acked-by: Dan Carpenter <error27@gmail.com>

regards,
dan carpenter
