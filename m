From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] vmxnet3: avoid assumption about invalid dma_pa in
 vmxnet3_set_mc()
Date: Sat, 15 Oct 2016 17:48:25 -0400 (EDT)
Message-ID: <20161015.174825.2149332278069508221.davem@davemloft.net>
References: <20161013.094323.1769619439752576215.davem@davemloft.net>
        <1476478880-22607-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: skhare@vmware.com, pv-drivers@vmware.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: khoroshilov@ispras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476478880-22607-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Date: Sat, 15 Oct 2016 00:01:20 +0300

> vmxnet3_set_mc() checks new_table_pa returned by dma_map_single()
> with dma_mapping_error(), but even there it assumes zero is invalid pa
> (it assumes dma_mapping_error(...,0) returns true if new_table is NULL).
> 
> The patch adds an explicit variable to track status of new_table_pa.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> v2: use "bool" and "true"/"false" for boolean variables.
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Applied.
