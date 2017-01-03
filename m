From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] ipv4: Do not allow MAIN to be alias for new LOCAL
 w/ custom rules
Date: Tue, 03 Jan 2017 09:39:09 -0500 (EST)
Message-ID: <20170103.093909.109725475584427798.davem@davemloft.net>
References: <20170102213214.13707.86757.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jjk@jjacky.com, dsa@cumulusnetworks.com
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36690 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752680AbdACOjL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 09:39:11 -0500
In-Reply-To: <20170102213214.13707.86757.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Mon, 02 Jan 2017 13:32:54 -0800

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> In the case of custom rules being present we need to handle the case of the
> LOCAL table being intialized after the new rule has been added.  To address
> that I am adding a new check so that we can make certain we don't use an
> alias of MAIN for LOCAL when allocating a new table.
> 
> Fixes: 0ddcf43d5d4a ("ipv4: FIB Local/MAIN table collapse")
> Reported-by: Oliver Brunel <jjk@jjacky.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Applied and queued up for -stable, thanks Alex.
