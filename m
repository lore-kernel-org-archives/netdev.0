From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v1 2/4] soc: ti: knav_dma: rename pad in struct knav_dma_desc to sw_data
Date: Fri, 19 Feb 2016 15:33:17 +0100
Message-ID: <4255231.ICxc506b9g@wuerfel>
References: <1455824777-15571-1-git-send-email-m-karicheri2@ti.com> <1455824777-15571-2-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455824777-15571-2-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 18 February 2016 14:46:15 Murali Karicheri wrote:
> Rename the pad to sw_data as per description of this field in the hardware
> spec(refer sprugr9 from www.ti.com). Latest version of the document is
> at http://www.ti.com/lit/ug/sprugr9h/sprugr9h.pdf and section 3.1
> Host Packet Descriptor describes this field.
> 
> Also define and use a constant for the size of sw_data field similar to
> other fields in the struct for desc and document the sw_data field
> in the header. As the sw_data is not touched by hw, it's type can be
> changed to u32.
> 
> 

Acked-by: Arnd Bergmann <arnd@arndb.de>
