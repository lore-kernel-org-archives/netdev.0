From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: MSI-X and interrupt affinity with Emulex be2net
Date: Thu, 19 Jan 2012 15:33:39 +0100
Message-ID: <CAL8zT=g_Vc-r-wZphGhyuDcBmSLsuSRWgoSnSQBS0zS=_3xRVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:47818 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753010Ab2ASOeB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 09:34:01 -0500
Received: by wics10 with SMTP id s10so408042wic.19
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2012 06:34:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I am using a be2net ethernet interface, and am on the master git
repository, so the latest kernel available.
I have MSI-X enabled of course, and as far as I can tell, all
interrupts are bound to CPU0.
I have several process and threads which use quite all the ethernet
interfaces I have, and I reach 7180 IRQs/sec on CPU0.

I have several questions regarding this :
- I thought MSI-X would help in balancing IRQs on different CPUs
- Is this a good idea anyway to specify which IRQ is bound to which
CPU manually, if I set the process using the IRQ to the same CPU ?
- How can I measure performance impact (using perf, probably) of no
balancing (ie, all on CPU0) versus balancing like explained above ?

Thanks for your advice !
JM
