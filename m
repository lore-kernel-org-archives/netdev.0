From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] bnx2x: fix memory leak in bnx2x_init_firmware()
Date: Fri, 16 Mar 2012 01:57:57 -0700 (PDT)
Message-ID: <20120316.015757.1890511102561562139.davem@davemloft.net>
References: <1331856509-9159-1-git-send-email-mschmidt@redhat.com>
	<1331856509-9159-2-git-send-email-mschmidt@redhat.com>
	<1331882675.4251.10.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mschmidt@redhat.com, netdev@vger.kernel.org, yuvalmin@broadcom.com,
	yanivr@broadcom.com, dmitry@broadcom.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36352 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031942Ab2CPI57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 04:57:59 -0400
In-Reply-To: <1331882675.4251.10.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Fri, 16 Mar 2012 09:24:34 +0200

> On Fri, 2012-03-16 at 01:08 +0100, Michal Schmidt wrote:
>> When cycling the interface down and up, bnx2x_init_firmware() knows that
>> the firmware is already loaded, but nevertheless it allocates certain
>> arrays anew (init_data, init_ops, init_ops_offsets, iro_arr). The old
>> arrays are leaked.
>> 
>> Fix the leaks by returning early if the firmware was already loaded.
>> Because if the firmware is loaded, so are the arrays.
>> 
>> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> 
> 
> Acked-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
