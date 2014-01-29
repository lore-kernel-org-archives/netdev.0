From: David Miller <davem@davemloft.net>
Subject: Re: llc: remove noisy WARN from llc_mac_hdr_init
Date: Tue, 28 Jan 2014 18:01:57 -0800 (PST)
Message-ID: <20140128.180157.1414191455730815665.davem@davemloft.net>
References: <20140128213052.GA10689@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48084 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752017AbaA2CCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jan 2014 21:02:00 -0500
In-Reply-To: <20140128213052.GA10689@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Tue, 28 Jan 2014 16:30:52 -0500

> Sending malformed llc packets triggers this spew, which seems excessive.
...
> Until 2009, this was a printk, when it was changed in
> bf9ae5386bc: "llc: use dev_hard_header".
> 
> Let userland figure out what -EINVAL means by itself.
> 
> Signed-off-by: Dave Jones <davej@fedoraproject.org>

Applied, thanks Dave.
