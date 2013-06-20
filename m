From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] sh_eth: get R8A7740 Rx descriptor word 0 shift out
 of #ifdef
Date: Wed, 19 Jun 2013 17:03:23 -0700 (PDT)
Message-ID: <20130619.170323.609697873999128436.davem@davemloft.net>
References: <201306132212.46361.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201306132212.46361.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Thu, 13 Jun 2013 22:12:45 +0400

> The only R8A7740 specific #ifdef hindering  ARM multiplatform build is  left in
> sh_eth_rx(): it covers the code shifting Rx buffer descriptor word 0 by 16. Get
> rid of the #ifdef by adding 'shift_rd0' field to the  'struct sh_eth_cpu_data',
> making the shift dependent on it, and setting it to 1 for the R8A7740 case...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
