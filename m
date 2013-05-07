From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 28/36] net: ethernet: ti: remove unnecessary platform_set_drvdata()
Date: Tue, 7 May 2013 11:00:06 +0530
Message-ID: <5188915E.1090609@ti.com>
References: <002d01ce4ade$d6c7da60$84578f20$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>,
	<netdev@vger.kernel.org>, "'Sekhar Nori'" <nsekhar@ti.com>,
	Wei Yongjun <yongjun_wei@trendmicro.com.cn>
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:51112 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752434Ab3EGFaZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 May 2013 01:30:25 -0400
In-Reply-To: <002d01ce4ade$d6c7da60$84578f20$@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/7/2013 10:23 AM, Jingoo Han wrote:
> The driver core clears the driver data to NULL after device_release
> or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
> (device-core: Ensure drvdata = NULL when no driver is bound).
> Thus, it is not needed to manually clear the device driver data to NULL.
>
> Signed-off-by: Jingoo Han<jg1.han@samsung.com>
Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
