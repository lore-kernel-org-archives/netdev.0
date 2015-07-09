From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3] cdc_ncm: Add support for moving NDP to end of NCM
 frame
Date: Thu, 09 Jul 2015 14:58:55 -0700 (PDT)
Message-ID: <20150709.145855.25174711066333213.davem@davemloft.net>
References: <1436353557-1959-1-git-send-email-mrkiko.rs@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: mrkiko.rs@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45871 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751177AbbGIV64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 17:58:56 -0400
In-Reply-To: <1436353557-1959-1-git-send-email-mrkiko.rs@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Enrico Mioso <mrkiko.rs@gmail.com>
Date: Wed,  8 Jul 2015 13:05:57 +0200

> NCM specs are not actually mandating a specific position in the frame for
> the NDP (Network Datagram Pointer). However, some Huawei devices will
> ignore our aggregates if it is not placed after the datagrams it points
> to. Add support for doing just this, in a per-device configurable way.
> While at it, update NCM subdrivers, disabling this functionality in all of
> them, except in huawei_cdc_ncm where it is enabled instead.
> We aren't making any distinction between different Huawei NCM devices,
> based on what the vendor driver does. Standard NCM devices are left
> unaffected: if they are compliant, they should be always usable, still
> stay on the safe side.
> 
> This change has been tested and working with a Huawei E3131 device (which
> works regardless of NDP position), a Huawei E3531 (also working both
> ways) and an E3372 (which mandates NDP to be after indexed datagrams).
> 
> V1->V2:
> - corrected wrong NDP acronym definition
> - fixed possible NULL pointer dereference
> - patch cleanup
> V2->V3:
> - Properly account for the NDP size when writing new packets to SKB
> 
> Signed-off-by: Enrico Mioso <mrkiko.rs@gmail.com>

Applied, thanks.
