From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] liquidio: stop using huge static buffer, save 4096k in
 .data
Date: Tue, 20 Jun 2017 15:21:42 -0400 (EDT)
Message-ID: <20170620.152142.1443468587541525646.davem@davemloft.net>
References: <20170619195052.13176-1-dvlasenk@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, felix.manlunas@cavium.com,
        prasad.kanneganti@cavium.com, derek.chickles@cavium.com,
        linux-kernel@vger.kernel.org
To: dvlasenk@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170619195052.13176-1-dvlasenk@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denys Vlasenko <dvlasenk@redhat.com>
Date: Mon, 19 Jun 2017 21:50:52 +0200

> Only compile-tested - I don't have the hardware.
> 
> From code inspection, octeon_pci_write_core_mem() appears to be safe wrt
> unaligned source. In any case, u8 fbuf[] was not guaranteed to be aligned
> anyway.
> 
> Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>

Looks good to me but I'll let one of the liquidio guys review this first
before I apply it.
