From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: linux-next: manual merge of the net tree with the i2c tree
Date: Mon, 26 Oct 2009 13:46:33 +0000
Message-ID: <1256564793.2783.3.camel@achroite>
References: <20091026133757.7cf87e49.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mika Kuoppala <mika.kuoppala@nokia.com>,
	Jean Delvare <khali@linux-fr.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:42341 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752361AbZJZNqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 09:46:31 -0400
In-Reply-To: <20091026133757.7cf87e49.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-10-26 at 13:37 +1100, Stephen Rothwell wrote:
> Hi all,
> 
> Today's linux-next merge of the net tree got a conflict in
> drivers/net/sfc/sfe4001.c between commit
> 3f7c0648f727a6d5baf6117653e4001dc877b90b ("i2c: Prevent priority
> inversion on top of bus lock") from the i2c tree and commit
> c9597d4f89565b6562bd3026adbe6eac6c317f47 ("sfc: Merge sfe4001.c into
> falcon_boards.c") from the net tree.
> 
> I have applied the following merge fixup patch (after removing
> drivers/net/sfc/sfe4001.c) and can carry it as necessary.
> 
> -- 
> Cheers,
> Stephen Rothwell                    sfr@canb.auug.org.au
> 
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Mon, 26 Oct 2009 12:24:55 +1100
> Subject: [PATCH] net: merge fixup for drivers/net/sfc/falcon_boards.c
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
Acked-by: Ben Hutchings <bhutchings@solarflare.com>

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

