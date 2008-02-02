From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: linux-2.6.24 compile error in drivers/net/b44.c
Date: Sat, 02 Feb 2008 12:51:40 +0800
Message-ID: <47A3F6DC.1000903@cn.fujitsu.com>
References: <47A3CC70.8090900@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	mboton@gmail.com, zambrano@broadcom.com, linville@tuxdriver.com
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61485 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754460AbYBBEwg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 23:52:36 -0500
In-Reply-To: <47A3CC70.8090900@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add CCs:

CC: mboton@gmail.com
CC: zambrano@broadcom.com
CC: linville@tuxdriver.com

Li Zefan wrote:
> drivers/net/b44.c: In function 'b44_remove_one':
> drivers/net/b44.c:2231: error: implicit declaration of function 'ssb_pcihost_set_power_state'
> make[2]: *** [drivers/net/b44.o] Error 1
> make[1]: *** [drivers/net] Error 2
> 
> I think it is caused by:
> 
> CONFIG_SSB_PCIHOST=n
> CONFIG_B44=y
> 


