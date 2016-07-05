From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] qeth: delete napi struct when removing a qeth
 device
Date: Mon, 04 Jul 2016 23:33:05 -0700 (PDT)
Message-ID: <20160704.233305.1481087690582871164.davem@davemloft.net>
References: <1467634036-49548-1-git-send-email-ubraun@linux.vnet.ibm.com>
	<1467634036-49548-2-git-send-email-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	stable@vger.kernel.org, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, utz.bacher@de.ibm.com
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56874 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752566AbcGEGdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 02:33:07 -0400
In-Reply-To: <1467634036-49548-2-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Date: Mon,  4 Jul 2016 14:07:16 +0200

> A qeth_card contains a napi_struct linked to the net_device during
> device probing. This struct must be deleted when removing the qeth
> device, otherwise Panic on oops can occur when qeth devices are
> repeatedly removed and added.
> 
> Fixes: a1c3ed4c9ca ("qeth: NAPI support for l2 and l3 discipline")
> Cc: stable@vger.kernel.org # v2.6.37+
> Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
> Tested-by: Alexander Klein <ALKL@de.ibm.com>

Applied, thanks.
