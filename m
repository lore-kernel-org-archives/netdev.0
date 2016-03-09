From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] validate variable length ll headers
Date: Wed, 09 Mar 2016 15:54:44 -0500 (EST)
Message-ID: <20160309.155444.1658110486757431732.davem@davemloft.net>
References: <1457124257-31486-1-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alan@linux.intel.com, hessu@hes.iki.fi,
	martin.blumenstingl@googlemail.com, linux-hams@vger.kernel.org,
	willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <1457124257-31486-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Fri,  4 Mar 2016 15:44:14 -0500

> From: Willem de Bruijn <willemb@google.com>
> 
> Allow device-specific validation of link layer headers. Existing
> checks drop all packets shorter than hard_header_len. For variable
> length protocols, such packets can be valid.
> 
> patch 1 adds header_ops.validate and dev_validate_header
> patch 2 replaces ll_header_truncated with dev_validate_header
> patch 3 implements the protocol specific callback for AX25
> 
> Tested with a temporary eth_header_validate function. The AX25
> code is compile-tested only at this point.

I'm not going to be able to send another pull request to Linus
before -final, so please respin this against net-next and I'll
queue it up for -stable.

You can add the missing Fixes: tags as well when you do this.

Thanks.
