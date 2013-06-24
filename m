From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] qlcnic: Do not sleep while holding spinlock
Date: Mon, 24 Jun 2013 00:29:03 -0700 (PDT)
Message-ID: <20130624.002903.698113277692903648.davem@davemloft.net>
References: <1371830982-18172-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	shahed.shaikh@qlogic.com, Dept_NX_Linux_NIC_Driver@qlogic.com
To: jitendra.kalsaria@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37740 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753035Ab3FXH3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 03:29:04 -0400
In-Reply-To: <1371830982-18172-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Date: Fri, 21 Jun 2013 12:09:42 -0400

> From: Shahed Shaikh <shahed.shaikh@qlogic.com>
> 
> This patch reverts commit a4791254b6625b06aa33e36304f6e8a1a4a1fdea
> ("qlcnic: change mdelay to msleep") which overwrote a commit
> 68b3f28c11bf896be32ad2a2e151aaa5f4a7c98e
> ("qlcnic: Fix scheduling while atomic bug")
> 
> Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
> Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Applied.
