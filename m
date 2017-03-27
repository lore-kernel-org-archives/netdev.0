From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH ethtool] ethtool: Support for configurable RSS hash
 function
Date: Mon, 27 Mar 2017 14:02:06 -0400
Message-ID: <20170327180203.GB29050@tuxdriver.com>
References: <1488981831-19376-1-git-send-email-galp@mellanox.com>
 <20170325145047.6a5a7967@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gal Pressman <galp@mellanox.com>, netdev@vger.kernel.org,
        Eyal Perry <eyalpe@mellanox.com>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46057 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751530AbdC0SPQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 14:15:16 -0400
Content-Disposition: inline
In-Reply-To: <20170325145047.6a5a7967@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 25, 2017 at 02:50:47PM -0700, Jakub Kicinski wrote:
> On Wed,  8 Mar 2017 16:03:51 +0200, Gal Pressman wrote:
> > This ethtool patch adds support to set and get the current RSS hash
> > function for the device through the new hfunc mask field in the
> > ethtool_rxfh struct. Kernel supported hash function names are queried
> > with ETHTOOL_GSTRINGS - each string is corresponding with a bit in hfunc
> > mask according to its index in the string-set.
> > 
> > Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
> > Signed-off-by: Gal Pressman <galp@mellanox.com>
> > Reviewed-by: Saeed Mahameed <saeedm@mellanox.com>
> 
> Hi John,
> 
> It seems you have applied both my earlier patch with get support and
> this:
> 
> adbaa18b9bc1 ("ethtool: Support for configurable RSS hash function")
> b932835d2302 ("ethtool: print hash function with ethtool -x|--show-rxfh-indir")
> 
> Now we print the RSS function twice:
> 
> RX flow hash indirection table for em4 with 4 RX ring(s):
>     0:      [...]
> RSS hash function: toeplitz  <--- from my adbaa18b9bc1
> RSS hash key:
> Operation not supported
> RSS hash function:           <--- from this patch
>     toeplitz: on
>     xor: off
>     crc32: off
> 
> Reverting my patch is probably the easiest way forward, although I find
> it more concise and easier to parse in test scripts :)

Thanks for pointing-out this issue! I apologize for my own confusion.

As you suggest, I will be reverting your patch.

Thanks,

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
