From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 1/1] ipv4: Prevent malformed UFO fragments in
 ip_append_page
Date: Tue, 14 Jun 2016 22:49:30 -0700 (PDT)
Message-ID: <20160614.224930.457532408906248954.davem@davemloft.net>
References: <6A051441C8B95A448E49718A747690B901CA76C84F@gbplmail03.genband.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, xiyou.wangcong@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: steven.caron@genband.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54303 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbcFOFtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 01:49:31 -0400
In-Reply-To: <6A051441C8B95A448E49718A747690B901CA76C84F@gbplmail03.genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steven Caron <steven.caron@genband.com>
Date: Mon, 13 Jun 2016 14:01:19 +0000

> As  the ip fragment offset field counts 8-byte chunks, non-final ip
> fragments must be multiples of 8 bytes of payload. Depending  on the
> mtu and ip option sizes, ip_append_page wasn't respecting this,
> notably when running NFS under UDP.
> 
> Signed-off-by: Steven Caron <steven.caron@genband.com>

This seems to have DOS newlines or something strange like that.

Please fix your email client to send clean patches.

Thanks.
