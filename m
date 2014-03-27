From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH net-next 0/6] at86rf230: cleanups and add missing
 devicetree documentation
Date: Thu, 27 Mar 2014 14:47:38 +0100
Message-ID: <20140327134736.GD22169@omega.Speedport_W_921V_1_24_000>
References: <1395843117-16494-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, devicetree@vger.kernel.org
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:44381 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754914AbaC0Nrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 09:47:42 -0400
Content-Disposition: inline
In-Reply-To: <1395843117-16494-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

please drop this patch-series I found a small issue on while
unloading the at86rf230 module.

We need to call devm_free_irq in remove callback before flush_work,
otherwise the interrupt will use some already freed memory.

I will rework this patch serie and send a v2, sorry.

- Alex
