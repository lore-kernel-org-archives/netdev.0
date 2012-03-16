From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] bnx2x: fix a crash on corrupt firmware file
Date: Fri, 16 Mar 2012 01:57:51 -0700 (PDT)
Message-ID: <20120316.015751.382113862064102627.davem@davemloft.net>
References: <1331856509-9159-1-git-send-email-mschmidt@redhat.com>
	<1331882650.4251.9.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mschmidt@redhat.com, netdev@vger.kernel.org, yuvalmin@broadcom.com,
	yanivr@broadcom.com, dmitry@broadcom.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36349 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031942Ab2CPI5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 04:57:54 -0400
In-Reply-To: <1331882650.4251.9.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Fri, 16 Mar 2012 09:24:09 +0200

> On Fri, 2012-03-16 at 01:08 +0100, Michal Schmidt wrote:
>> If the requested firmware is deemed corrupt and then released, reset the
>> pointer to NULL in order to avoid double-freeing it in
>> bnx2x_release_firmware() or dereferencing it in bnx2x_init_firmware().
>> 
>> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> 
> Acked-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
