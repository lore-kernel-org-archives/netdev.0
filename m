From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] macvtap: add namespace support to the sysfs
 device class
Date: Sun, 24 Apr 2016 14:14:34 -0400 (EDT)
Message-ID: <20160424.141434.235855672965106874.davem@davemloft.net>
References: <1461161491-22867-1-git-send-email-marc@arista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: marc@arista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52445 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751704AbcDXSOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2016 14:14:38 -0400
In-Reply-To: <1461161491-22867-1-git-send-email-marc@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Angel <marc@arista.com>
Date: Wed, 20 Apr 2016 16:11:31 +0200

> However, doing this has the side effect of changing
> /sys/devices/virtual/net/macvtapX/tapNN  into
> /sys/devices/virtual/net/macvtapX/macvtap/tapNN

I'm really not comfortable at all with having this sysfs
device name change.
