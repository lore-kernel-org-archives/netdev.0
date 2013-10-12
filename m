From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH] usbnet: fix error return code in usbnet_probe()
Date: Sat, 12 Oct 2013 14:19:56 +0200
Message-ID: <1381580396.21507.0.camel@linux-fkkt.site>
References: <CAPgLHd9jQfT2Kzi5o+3KPy0hFrkHL135K2aYp7OXcbLX4Cmkcg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:43737 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752189Ab3JLMUB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Oct 2013 08:20:01 -0400
In-Reply-To: <CAPgLHd9jQfT2Kzi5o+3KPy0hFrkHL135K2aYp7OXcbLX4Cmkcg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-10-12 at 14:24 +0800, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fix to return -ENOMEM in the padding pkt alloc fail error handling
> case instead of 0, as done elsewhere in this function.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
Acked-by: Oliver Neukum <oneukum@suse.de>
