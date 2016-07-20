From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resend] virtio-net: Remove more stack DMA
Date: Tue, 19 Jul 2016 19:26:04 -0700 (PDT)
Message-ID: <20160719.192604.333351511286408057.davem@davemloft.net>
References: <c2ebc30cc66aeccba56f6c49527c8a9fa04332cf.1468881101.git.luto@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: x86@kernel.org, bp@alien8.de, linux-kernel@vger.kernel.org,
	mst@redhat.com, netdev@vger.kernel.org
To: luto@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c2ebc30cc66aeccba56f6c49527c8a9fa04332cf.1468881101.git.luto@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 18 Jul 2016 15:34:49 -0700

> VLAN and MQ control was doing DMA from the stack.  Fix it.
> 
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> ---
> 
> I tested VLAN addition and removal with CONFIG_VMAP_STACK=y,
> CONFIG_DEBUG_SG=y and it got rid of the warnings I saw.  I haven't
> tested the MQ part because I don't know how to enable it in the first
> place (I'm guessing it needs me to enable some QEMU feature I don't
> know about.)
> 
> DaveM, contrary to what I thought last time I sent this, I think this
> should go through net-next as long as it makes it in time for 4.8.

Applied to net-next, thanks.
