From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/ncsi: Don't limit vids based on hot_channel
Date: Wed, 11 Oct 2017 20:13:19 -0700 (PDT)
Message-ID: <20171011.201319.1327623357814721573.davem@davemloft.net>
References: <20171011055427.30227-1-sam@mendozajonas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: sam@mendozajonas.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171011055427.30227-1-sam@mendozajonas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Mendoza-Jonas <sam@mendozajonas.com>
Date: Wed, 11 Oct 2017 16:54:27 +1100

> Currently we drop any new VLAN ids if there are more than the current
> (or last used) channel can support. Most importantly this is a problem
> if no channel has been selected yet, resulting in a segfault.
> 
> Secondly this does not necessarily reflect the capabilities of any other
> channels. Instead only drop a new VLAN id if we are already tracking the
> maximum allowed by the NCSI specification. Per-channel limits are
> already handled by ncsi_add_filter(), but add a message to set_one_vid()
> to make it obvious that the channel can not support any more VLAN ids.
> 
> Signed-off-by: Samuel Mendoza-Jonas <sam@mendozajonas.com>

Applied, thanks.
