From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/7] qlge: Fixed packet transmit errors due to
 potential driver errors.
Date: Mon, 02 Jul 2012 17:18:54 -0700 (PDT)
Message-ID: <20120702.171854.1585295090835924398.davem@davemloft.net>
References: <1341272514-5156-1-git-send-email-jitendra.kalsaria@qlogic.com>
	<1341272514-5156-2-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com
To: jitendra.kalsaria@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33357 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753515Ab2GCASz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 20:18:55 -0400
In-Reply-To: <1341272514-5156-2-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Date: Mon,  2 Jul 2012 19:41:48 -0400

> From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
> 
> qlge driver was acting wrongly when considering TX ring full
> as a TX error. TX ring full is expected behavior when NIC is
> overwhelmed and is expected to happen, as far as packets are
> not lost.
> 
> Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

If your driver is properly coded, this code path should never trigger,
ever.  So it is an error, and you need to fix whatever bug exists in
your driver which allows this to happen, rather than this change
here which attempts to sweep the issue under the rug.
