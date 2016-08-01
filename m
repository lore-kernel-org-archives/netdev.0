From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: bna: use correct type specifications
Date: Mon, 01 Aug 2016 13:44:14 -0700 (PDT)
Message-ID: <20160801.134414.165620406323267678.davem@davemloft.net>
References: <1469955194-30017-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rasesh.mody@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: xypron.glpk@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54618 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751090AbcHAUpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2016 16:45:22 -0400
In-Reply-To: <1469955194-30017-1-git-send-email-xypron.glpk@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Date: Sun, 31 Jul 2016 10:53:14 +0200

> addr and len are read with
> sscanf(kern_buf, "%x:%x", &addr, &len);
> and used as arguments for
> bna_reg_offset_check.
> 
> So they have to be unsigned.
> 
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>

Applied.
