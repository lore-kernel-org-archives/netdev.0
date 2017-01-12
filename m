From: Lino Sanfilippo <lsanfil@marvell.com>
Subject: Re: [PATCH/RFC v2 net-next] ravb: unmap descriptors when freeing
 rings
Date: Thu, 12 Jan 2017 14:23:48 +0100
Message-ID: <d840eddd-f6a3-fe8c-dbaa-242c117b5274@marvell.com>
References: <1483613000-537-1-git-send-email-horms+renesas@verge.net.au>
 <6fcec500-bed6-ffa3-2887-d45b34703682@cogentembedded.com>
 <20170112091116.GC7724@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Magnus Damm <magnus.damm@gmail.com>, <netdev@vger.kernel.org>,
        <linux-renesas-soc@vger.kernel.org>
To: Simon Horman <horms@verge.net.au>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20170112091116.GC7724@verge.net.au>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 12.01.2017 10:11, Simon Horman wrote:

>>> +
>>> +	for (; priv->cur_tx[q] - priv->dirty_tx[q] > 0; priv->dirty_tx[q]++) {

BTW: How can this work correctly when cur_tx wraps and dirty_tx is greater?

Regards,
Lino
