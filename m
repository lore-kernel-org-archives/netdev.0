From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] xen-netback: fix extra_info handling in
 xenvif_tx_err()
Date: Fri, 13 May 2016 01:59:33 -0400 (EDT)
Message-ID: <20160513.015933.2279812693973875280.davem@davemloft.net>
References: <1463060583-7524-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	wei.liu2@citrix.com
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33676 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104AbcEMF7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 01:59:35 -0400
In-Reply-To: <1463060583-7524-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <paul.durrant@citrix.com>
Date: Thu, 12 May 2016 14:43:03 +0100

> Patch 562abd39 "xen-netback: support multiple extra info fragments
> passed from frontend" contained a mistake which can result in an in-
> correct number of responses being generated when handling errors
> encountered when processing packets containing extra info fragments.
> This patch fixes the problem.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Reported-by: Jan Beulich <JBeulich@suse.com>

Applied.
