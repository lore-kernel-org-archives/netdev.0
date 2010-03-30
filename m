From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 v7 00/12] net-caif: introducing CAIF protocol stack
Date: Wed, 31 Mar 2010 01:16:29 +0200
Message-ID: <1269990989-12383-1-git-send-email-sjur.brandeland@stericsson.com>
References: <1269934228-23292-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: daniel.martensson@stericsson.com, sjurbr@gmail.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: davem@davemloft.net, netdev@vger.kernel.org, marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eterpe-smout.broadpark.no ([80.202.8.16]:53087 "EHLO
	eterpe-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756381Ab0C3XQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 19:16:54 -0400
Received: from ignis-smin.broadpark.no ([unknown] [80.202.8.11])
 by eterpe-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L0400CAABC4AR00@eterpe-smout.broadpark.no> for
 netdev@vger.kernel.org; Wed, 31 Mar 2010 01:16:52 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.207])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L0400390BC3WM50@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Wed, 31 Mar 2010 01:16:52 +0200 (CEST)
In-reply-to: <1269934228-23292-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Hi David.

>You're directly accessing SKB data members instead of using
>the portable interfaces defined in linux/skbuff.h, therefore
>the build fails on 64-bit.

Sorry for the inconvenience I have caused you David.

>How many revisions of this patch set and not once has it been even
>build tested on 64-bit?
We have been doing all our testing on ARM and x86 so far,
64bit slipped our attention.

I have compiled for x86, x86-64 bit, run sparce and checkpatch -strict,
compiled with -W, and already compiled for ARM.
Do you want a new patch-set now, or would you rather wait for completion of
all checks in 'SubmitPaches'? I'm missing at least steps: 2, 3, 4, 10, 21.

BR/Sjur
