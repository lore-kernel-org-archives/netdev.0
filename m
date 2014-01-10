From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/1] drivers: net: silence compiler warning in smc91x.c
Date: Fri, 10 Jan 2014 23:42:41 +0300
Message-ID: <52D05B41.7000601@cogentembedded.com>
References: <1389323046-4521-1-git-send-email-pankaj.dubey@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jingoo Han <jg1.han@samsung.com>, netdev@vger.kernel.org
To: Pankaj Dubey <pankaj.dubey@samsung.com>,
	linux-samsung-soc@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-Reply-To: <1389323046-4521-1-git-send-email-pankaj.dubey@samsung.com>
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 01/10/2014 06:04 AM, Pankaj Dubey wrote:

> If used 64 bit compiler GCC warns that:

> drivers/net/ethernet/smsc/smc91x.c:1897:7:
> warning: cast from pointer to integer of different
> size [-Wpointer-to-int-cast]

> This patch fixes this by changing typecase from "unsigned int" to "unsigned long"

    Only "typecast".

> CC: "David S. Miller" <davem@davemloft.net>
> CC: Jingoo Han <jg1.han@samsung.com>
> CC: netdev@vger.kernel.org
> Signed-off-by: Pankaj Dubey <pankaj.dubey@samsung.com>

WBR, Sergei
