From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/5] qlcnic: Mailbox refactoring
Date: Thu, 01 Aug 2013 23:04:56 -0700 (PDT)
Message-ID: <20130801.230456.1812905714664888247.davem@davemloft.net>
References: <cover.1375438720.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: himanshu.madhani@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59029 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753082Ab3HBGE5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 02:04:57 -0400
In-Reply-To: <cover.1375438720.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Date: Fri, 2 Aug 2013 00:57:38 -0400

> From: Himanshu Madhani <himanshu.madhani@qlogic.com>
> 
> This series contains following patches 
> 
> o in v2 series, we received feedback on return codes to use standard error
>   codes instead of mixing custom error codes. We have modified patch for 
>   loopback diagnostic test to return standard error codes.
> 
> o rest of the 3 patches in the series are for mailbox refactoring
> 
>   Current driver-firmware mailbox interface was operating in polling mode
>   because of some limitations with the earlier versions of 83xx adapter
>   firmware. These issues are resolved now and we are implementing the
>   mailbox interface in interrupt mode.
> 
>   There are three patches which refactors mailbox handling:
>   * Interrupt mode mailbox implantation.
>   * Replace poll mode mailbox interfaces with interrupt mode interfaces.
>   * Operate mailbox in poll mode when interrupts are not available.
> 
> changes from v2 -> v3
>  * Addressed review feedback to use standard return codes for loopback
>    diagnostic test.
> 
> Please consider applying these patches to net-next.

Series applied, thanks.
