From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6] Intersil Prism54 wireless driver
Date: Wed, 10 Mar 2004 21:43:08 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <404FD23C.4020205@pobox.com>
References: <20040304023524.GA19453@bougret.hpl.hp.com> <20040310165548.A24693@infradead.org> <20040310172114.GA8867@bougret.hpl.hp.com> <404F5097.4040406@pobox.com> <20040310175200.GA9531@bougret.hpl.hp.com> <404F5744.1040201@pobox.com> <404FA6AC.7040009@linux.co.intel.com> <20040311023141.GB3738@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: James Ketrenos <jketreno@linux.co.intel.com>, jt@hpl.hp.com,
        Christoph Hellwig <hch@infradead.org>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        Linux kernel mailing list <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jouni Malinen <jkmaline@cc.hut.fi>
In-Reply-To: <20040311023141.GB3738@jm.kir.nu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jouni Malinen wrote:
> done, I would hope to get the code merged into the kernel tree either
> with full Host AP driver or separately. One option would be to first add
> Host AP driver in its current structure (i.e., everything in
> drivers/net/wireless) and then create a new directory (net/ieee80211 ?)
> for generic IEEE 802.11 functionality and start moving things like the
> IEEE 802.11 encryption into the new location.

Given the discussion today, I think my preference is to merge all of 
HostAP into the wireless-2.6 tree I just created, then submit patches to 
that which create and populate net/802_11.  Once the work on that is 
mostly done, it can get merged back into the main upstream tree.

	Jeff
