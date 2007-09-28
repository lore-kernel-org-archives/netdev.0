From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: sfq
Date: Fri, 28 Sep 2007 15:54:54 -0700
Message-ID: <11910200972768-git-send-email-bugfood-ml@fatooh.org>
References: <1191019977201-git-send-email-bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:42967 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754480AbXI1WzG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2007 18:55:06 -0400
Received: from localhost (localhost [127.0.0.1])
	by hot.fatooh.org (Postfix) with ESMTP id 4908017C0D6
	for <netdev@vger.kernel.org>; Fri, 28 Sep 2007 17:55:06 -0500 (CDT)
Received: from hot.fatooh.org ([127.0.0.1])
	by localhost (hot.fatooh.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id XEXdXE20vdV1 for <netdev@vger.kernel.org>;
	Fri, 28 Sep 2007 17:55:06 -0500 (CDT)
Received: from bugfood (c-24-7-71-25.hsd1.ca.comcast.net [24.7.71.25])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by hot.fatooh.org (Postfix) with ESMTP id 0E7A117C24B
	for <netdev@vger.kernel.org>; Fri, 28 Sep 2007 17:55:06 -0500 (CDT)
In-Reply-To: <1191019977201-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


These patches follow the ESFQ-->SFQ kernel patches. See the kernel
patch summary for general information.

Thanks,
Corey



 include/linux/pkt_sched.h |   23 ++++++++++++++---------
 tc/q_sfq.c                |   43 ++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 52 insertions(+), 14 deletions(-)


[PATCH 1/3] SFQ: Support changing depth and divisor.
[PATCH 2/3] Change perturb_period to unsigned.
[PATCH 3/3] Use nested compat attributes for passing parameters to the kernel.
