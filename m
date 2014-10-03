From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] r8152: nway reset after setting eee
Date: Fri, 03 Oct 2014 15:08:07 -0700 (PDT)
Message-ID: <20141003.150807.1695488392631084970.davem@davemloft.net>
References: <1394712342-15778-54-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-54-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Thu, 2 Oct 2014 16:01:22 +0800

> @@ -3480,6 +3480,9 @@ rtl_ethtool_set_eee(struct net_device *net, struct ethtool_eee *edata)
>  
>  	ret = tp->rtl_ops.eee_set(tp, edata);
>  
> +	if (ret == 0)
> +		ret = mii_nway_restart(&tp->mii);

Please test this canonically as "if (!ret)" and delete the empty line between the function
call and the return value test.

Thank you.
