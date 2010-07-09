From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: linux-next: manual merge of the wireless tree with the net tree
Date: Fri, 09 Jul 2010 12:59:16 +0300
Message-ID: <1278669556.25296.1.camel@chilepepper>
References: <20100709115119.6c88f8d2.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: ext Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100709115119.6c88f8d2.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

On Fri, 2010-07-09 at 03:51 +0200, ext Stephen Rothwell wrote:
> Hi John,
> 
> Today's linux-next merge of the wireless tree got a conflict in
> drivers/net/wireless/wl12xx/wl1271_cmd.h between commit
> ba2d3587912f82d1ab4367975b1df460db60fb1e ("drivers/net: use __packed
> annotation") from the net tree and commit
> 34dd2aaac4a4b908c093980a9894fd878aeb6deb ("wl1271: moved scan operations
> to a separate file") from the wireless tree.
> 
> I didn't bother changing __attribute((packed)) to __packed where this
> code has been moved to.  Maybe someone could write a patch to do that ...

I'll submit a patch to change all the instances of __attribute((packed))
to __packed in the wl1271 driver.


-- 
Cheers,
Luca.
