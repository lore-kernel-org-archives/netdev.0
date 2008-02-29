From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26] Use existing device list walker for
 /proc/dev_mcast.
Date: Fri, 29 Feb 2008 11:44:24 -0800 (PST)
Message-ID: <20080229.114424.229375788.davem@davemloft.net>
References: <47C82EEE.1040409@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59380
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758390AbYB2ToZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 14:44:25 -0500
In-Reply-To: <47C82EEE.1040409@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 29 Feb 2008 19:12:30 +0300

> The seq_file_operations' dev_mc_seq_xxx callbacks do the same 
> thing as the dev_seq_xxx ones do, but skip the SEQ_START_TOKEN.
> 
> So use the existing exported dev_seq_xxx calls and handle the 
> SEQ_START_TOKEN in the dev_mc_seq_show().
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Nice simplification, applied.
