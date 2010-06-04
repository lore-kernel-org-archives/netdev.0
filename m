From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: linux-next: manual merge of the wireless tree with the net tree
Date: Fri, 04 Jun 2010 09:14:24 +0300
Message-ID: <1275632064.15894.18.camel@chilepepper>
References: <20100604114801.df31fb50.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Oikarinen Juuso (Nokia-D/Tampere)" <juuso.oikarinen@nokia.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: ext Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100604114801.df31fb50.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-06-04 at 03:48 +0200, ext Stephen Rothwell wrote:
> Hi John,
> 
> Today's linux-next merge of the wireless tree got a conflict in
> drivers/net/wireless/wl12xx/wl1271.h
> drivers/net/wireless/wl12xx/wl1271_cmd.h between commit
> ba2d3587912f82d1ab4367975b1df460db60fb1e ("drivers/net: use __packed
> annotation") from the net tree and commit
> eb70eb723b489dd4e233e22e47d993f59858cdd8 ("wl1271: Update handling of the
> NVS file / INI parameters") from the wireless tree.
> 
> I fixed up some if it (see below) and can carry the fixes as necessary.
> The latter patch also moved some of the structures to another file
> (drivers/net/wireless/wl12xx/wl1271_ini.h), so they will need fixing up
> there.

Acked-by: Luciano Coelho <luciano.coelho@nokia.com>

Thanks for the merge.  I'll submit a new patch fixing the annotation
from the structs that were moved.

-- 
Cheers,
Luca.
