From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 5/5] net/ncsi: Fix length of GVI response packet
Date: Sat, 21 Oct 2017 01:57:26 +0100 (WEST)
Message-ID: <20171021.015726.910376579423539079.davem@davemloft.net>
References: <20171019024309.13628-1-sam@mendozajonas.com>
        <20171019024309.13628-5-sam@mendozajonas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gwshan@linux.vnet.ibm.com,
        linux-kernel@vger.kernel.org
To: sam@mendozajonas.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171019024309.13628-5-sam@mendozajonas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Mendoza-Jonas <sam@mendozajonas.com>
Date: Thu, 19 Oct 2017 13:43:09 +1100

> From: Gavin Shan <gwshan@linux.vnet.ibm.com>
> 
> The length of GVI (GetVersionInfo) response packet should be 40 instead
> of 36. This issue was found from /sys/kernel/debug/ncsi/eth0/stats.
> 
>  # ethtool --ncsi eth0 swstats
>      :
>  RESPONSE     OK       TIMEOUT  ERROR
>  =======================================
>  GVI          0        0        2
> 
> With this applied, no error reported on GVI response packets:
> 
>  # ethtool --ncsi eth0 swstats
>      :
>  RESPONSE     OK       TIMEOUT  ERROR
>  =======================================
>  GVI          2        0        0
> 
> Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
> Signed-off-by: Samuel Mendoza-Jonas <sam@mendozajonas.com>

Applied.
