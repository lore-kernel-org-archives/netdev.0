From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add APIs for manipulating skb page fragments.
Date: Sat, 20 Aug 2011 17:31:33 -0700 (PDT)
Message-ID: <20110820.173133.1612902138924735868.davem@davemloft.net>
References: <1313771100-22993-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com, mirq-linux@rere.qmqm.pl
To: ian.campbell@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313771100-22993-1-git-send-email-ian.campbell@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ian Campbell <ian.campbell@citrix.com>
Date: Fri, 19 Aug 2011 17:25:00 +0100

> The primary aim is to add skb_frag_(ref|unref) in order to remove the use of
> bare get/put_page on SKB pages fragments and to isolate users from subsequent
> changes to the skb_frag_t data structure.
> 
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>

You're going to have to protect all of the things using the interfaces
from linux/dma-mapping.h with CONFIG_HAS_DMA otherwise it won't build
on platforms like S390.
