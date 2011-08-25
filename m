From: Rongqing Li <rongqing.li@windriver.com>
Subject: When set mtu 9600 by gfar_change_mtu, the maxfrm register is greater
 than 9600
Date: Thu, 25 Aug 2011 17:24:18 +0800
Message-ID: <4E5614C2.4090705@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linuxppc-dev@lists.ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53616 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006Ab1HYJYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 05:24:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

When set MTU to 9600 by gfar_change_mtu(), the maxfrm register will
be set to 9728 which is greater than 9600 in gianfar.c.

But the MPC8315 Reference manual says the value of maxfrm can not
greater than 9600.

Is it a defect, Do we need to fix it?


-- 
Best Reagrds,
Roy | RongQing Li
