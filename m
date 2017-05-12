From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tools: hv: Add clean up for included files in
 Ubuntu net config
Date: Fri, 12 May 2017 12:20:26 -0400 (EDT)
Message-ID: <20170512.122026.71874509847193117.davem@davemloft.net>
References: <1494598413-19106-1-git-send-email-haiyangz@exchange.microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
        vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com, haiyangz@exchange.microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1494598413-19106-1-git-send-email-haiyangz@exchange.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Date: Fri, 12 May 2017 07:13:33 -0700

>  
> +	local fn
> +	for fn in "${fnlist[@]}"
> +	do
>  	awk "/$nic_end/{x=0} x{next} /$nic_start/{x=1;next} 1"  $fn >$tmpfl
>  
>  	cp $tmpfl $fn
> +	done

Please indent the body of this loop properly.
