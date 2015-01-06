From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netback: fixing the propagation of the transmit
 shaper timeout
Date: Tue, 06 Jan 2015 14:18:05 -0500 (EST)
Message-ID: <20150106.141805.2295183028829066436.davem@davemloft.net>
References: <1420559084-28370-1-git-send-email-imrep.amz@gmail.com>
	<1420559647.28863.174.camel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: imrep.amz@gmail.com, xen-devel@lists.xenproject.org,
	netdev@vger.kernel.org, wei.liu2@citrix.com,
	linux-kernel@vger.kernel.org, imrep@amazon.de, aliguori@amazon.com
To: Ian.Campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53131 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187AbbAFTSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 14:18:07 -0500
In-Reply-To: <1420559647.28863.174.camel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Tue, 6 Jan 2015 15:54:07 +0000

> On Tue, 2015-01-06 at 16:44 +0100, Imre Palik wrote:
>> From: "Palik, Imre" <imrep@amazon.de>
>> 
>> Since e9ce7cb6b107 ("xen-netback: Factor queue-specific data into queue struct"),
>> the transimt shaper timeout is always set to 0.  The value the user sets via
>> xenbus is never propagated to the transmit shaper.
>> 
>> This patch fixes the issue.
>> 
>> Cc: Anthony Liguori <aliguori@amazon.com>
>> Signed-off-by: Imre Palik <imrep@amazon.de>
> 
> Acked-by: Ian Campbell <ian.campbell@citrix.com>

Applied and queued up for -stable, thanks.
