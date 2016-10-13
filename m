From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vmxnet3: avoid assumption about invalid dma_pa in
 vmxnet3_set_mc()
Date: Thu, 13 Oct 2016 09:43:23 -0400 (EDT)
Message-ID: <20161013.094323.1769619439752576215.davem@davemloft.net>
References: <1475895223-3225-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: skhare@vmware.com, pv-drivers@vmware.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: khoroshilov@ispras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1475895223-3225-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Date: Fri,  7 Oct 2016 22:53:43 -0400

> vmxnet3_set_mc() still assumes zero is invalid pa:
>   it assumes dma_mapping_error(...,0) returns true if vmxnet3_copy_mc() fails;
>   it calls dma_unmap_single() iff new_table_pa is not zero.
> 
> The patch adds an explicit variable to track status of new_table_pa.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Please use "bool" and "true"/"false" for boolean variables.

Thanks.
