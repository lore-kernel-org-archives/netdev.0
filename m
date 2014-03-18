From: Olaf Hering <olaf@aepfle.de>
Subject: Re: hv_netvsc calls RTM_NEWLINK with eth%d
Date: Tue, 18 Mar 2014 21:17:43 +0100
Message-ID: <20140318201743.GA10463@aepfle.de>
References: <20140318185218.GA28692@aepfle.de>
 <2b804c0c102e471ebb6a933995f7dba6@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: KY Srinivasan <kys@microsoft.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.219]:31763 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757661AbaCRURq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 16:17:46 -0400
Content-Disposition: inline
In-Reply-To: <2b804c0c102e471ebb6a933995f7dba6@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 18, Haiyang Zhang wrote:

> Yes, and actually I have already added a condition in
> netvsc_linkstatus_callback(), so that netdev_notify_peers() won't be
> called before netdevice is registered.
> 
> The commit:
> http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/drivers/net/hyperv?id=891de74d693bb4fefe2efcc6432a4a9a9bee561e

This helps. Thanks!

Olaf
