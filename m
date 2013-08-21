From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] sh_eth: get register layout from 'struct
 sh_eth_cpu_data'
Date: Tue, 20 Aug 2013 17:05:36 -0700 (PDT)
Message-ID: <20130820.170536.1573745208374127042.davem@davemloft.net>
References: <201308180308.39941.sergei.shtylyov@cogentembedded.com>
	<201308180311.28814.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201308180311.28814.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sun, 18 Aug 2013 03:11:28 +0400

> The register layout is a SoC characteristic, so it's wrong that it's stored
> in the otherwise board specific platform data. Add 'register_type' field to
> 'struct sh_eth_cpu_data', initialize it properly for each SoC, and read  it
> from this structure instead of the platfrom data from now on...  
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
