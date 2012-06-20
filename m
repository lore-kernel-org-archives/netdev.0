From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net-next 07/14] Fix intel/ixgbe
Date: Wed, 20 Jun 2012 10:55:14 +0200
Message-ID: <1340182514.4604.843.camel@edumazet-glaptop>
References: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
	 <1340118848-30978-8-git-send-email-yuvalmin@broadcom.com>
	 <4FE0A0CD.5050909@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yuval Mintz <yuvalmin@broadcom.com>, netdev@vger.kernel.org,
	davem@davemloft.net, eilong@broadcom.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:33693 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755703Ab2FTIzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 04:55:20 -0400
Received: by bkcji2 with SMTP id ji2so5924872bkc.19
        for <netdev@vger.kernel.org>; Wed, 20 Jun 2012 01:55:18 -0700 (PDT)
In-Reply-To: <4FE0A0CD.5050909@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-19 at 08:54 -0700, Alexander Duyck wrote:

> This patch doesn't limit the number of queues.  It is limiting the
> number of interrupts.  The two are not directly related as we can
> support multiple queues per interrupt.
> 
> Also this change assumes we are only using receive side scaling.  We
> have other features such as DCB, FCoE, and Flow Director which require
> additional queues.
> 

Yet, it would be good if ixgbe doesnt allocate 36 queues on a 4 cpu
machine.

"tc -s class show dev eth0" output is full of not used classes.
