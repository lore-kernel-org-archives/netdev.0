From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [git patches] net driver fixes for 2.6.28-rc
Date: Mon, 3 Nov 2008 23:07:58 +0100
Message-ID: <B9DCBB9E-9DE3-4114-9FFC-7A7C0C3DA920@holtmann.org>
References: <20081103205121.GA6005@havoc.gtf.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:52880 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754316AbYKCWIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 17:08:04 -0500
In-Reply-To: <20081103205121.GA6005@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

> Please pull from 'davem-fixes' branch of
> master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git  
> davem-fixes
>
> to receive the following updates:
>
> drivers/net/Kconfig                |   18 +++++++++++++++---
> drivers/net/fs_enet/fs_enet-main.c |    6 ++++--
> drivers/net/mv643xx_eth.c          |    9 ++++++---
> 3 files changed, 25 insertions(+), 8 deletions(-)

are you also queuing patches for drivers/net/usb/hso.c, because the  
current state of that driver is fully broken. It oopses and shows up  
with a WLAN RFKILL switch instead of WWAN. Also it has some weird  
disconnect race with the TTY layer. Some patches have been posted, but  
seems that nobody has picked them up so far.

Regards

Marcel

