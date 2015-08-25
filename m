From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] enic: reduce ioread in devcmd2
Date: Tue, 25 Aug 2015 16:06:02 -0700 (PDT)
Message-ID: <20150825.160602.1484804680784225150.davem@davemloft.net>
References: <1440492311-22950-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60201 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753186AbbHYXGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 19:06:04 -0400
In-Reply-To: <1440492311-22950-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Tue, 25 Aug 2015 14:15:11 +0530

> posted_index is RO in firmware. We need not do ioread everytime to get
> posted index. Store posted index locally.
> 
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
> ---
> v2: initialize devcmd2->posted properly in vnic_dev_init_devcmd2

Applied, thanks.
