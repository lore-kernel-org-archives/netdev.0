From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] Add support to download EEE firmware for
 the 57766
Date: Thu, 07 Mar 2013 15:32:02 -0500 (EST)
Message-ID: <20130307.153202.775624726449165426.davem@davemloft.net>
References: <1362625354-15095-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nsujir@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45816 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933270Ab3CGUcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 15:32:04 -0500
In-Reply-To: <1362625354-15095-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Date: Wed, 6 Mar 2013 19:02:28 -0800

> For the 57766 devices with no NVRAM, there is not enough space for the complete
> boot code with EEE support. On these devices, the tg3 driver has to download
> a service patch firmware to the scratchpad for the boot code to execute. This
> patchset adds support to do the above.
> 
> A major portion of this patchset is refactoring the existing firmware download
> section to allow a cleaner merge of the 57766 download. The 57766 firmware
> differs from previous firmware in that it's not written to a contiguous area in
> memory. It consists of multiple fragments to be written to different locations.
> The patchset makes an attempt to make the new firmware format to be an
> extension of the existing format.

Series applied, thanks.
