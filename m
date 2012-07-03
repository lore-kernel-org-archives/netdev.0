From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/7] qlge: Fixed packet transmit errors due to
 potential driver errors.
Date: Mon, 02 Jul 2012 18:41:34 -0700 (PDT)
Message-ID: <20120702.184134.1131493483786674336.davem@davemloft.net>
References: <20120702.171854.1585295090835924398.davem@davemloft.net>
	<5E4F49720D0BAD499EE1F01232234BA877435B266A@AVEXMB1.qlogic.org>
	<20120702.183826.1521103644475572622.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com
To: jitendra.kalsaria@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34171 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932563Ab2GCBlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 21:41:35 -0400
In-Reply-To: <20120702.183826.1521103644475572622.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 02 Jul 2012 18:38:26 -0700 (PDT)

> From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
> Date: Mon, 2 Jul 2012 18:30:47 -0700
> 
>> As per your comments, TX ring full is not expected behavior? All I
>> can think of increasing the TX queue to 1024 and clean-up in timer
>> instead of interrupt?
> 
> Your transmit function should never be invoked when the queue is
> full, logic elsewhere in your driver should have stopped the queue
> therefore preventing further invocations of your transmit function
> until you wake the queue when space is liberated in the TX ring.

BTW, did it even occur to you that there is a kernel log message here
in this code path for a reason?

That log message is there because this event is unexpected and a
driver error.
