From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: Inconsistent use of size argument in kzalloc and memcpy in
 'drivers/net/ethernet/toshiba/ps3_gelic_wireless.c'
Date: Mon, 11 Apr 2016 13:26:08 +0300
Message-ID: <20160411102608.GC4298@mwanda>
References: <570B75A4.5070904@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: geoff@infradead.org, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, kernel-janitors@vger.kernel.org
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <570B75A4.5070904@wanadoo.fr>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 11, 2016 at 12:00:04PM +0200, Christophe JAILLET wrote:
> Hi,
> 
> while looking at potential clean-up, I ended on the following code
> which looks spurious to me.
> 
> We allocate 'be16_to_cpu(scan_info->size)' bytes, but then copy
> 'scan_info->size'.
> This is not consistent.
> 

Good catch.  be16_to_cpu(scan_info->size) is correct.  It's surprising
that this bug wasn't caught in testing...

regards,
dan carpenter

