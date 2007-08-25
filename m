From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [PATCH 0/3][iproute2] SFQ: backport some features from ESFQ
Date: Sat, 25 Aug 2007 15:30:25 -0700
Message-ID: <11880810281854-git-send-email-bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:41395 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757760AbXHYWa2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Aug 2007 18:30:28 -0400
Received: from localhost (localhost [127.0.0.1])
	by hot.fatooh.org (Postfix) with ESMTP id EDE9117C315
	for <netdev@vger.kernel.org>; Sat, 25 Aug 2007 17:30:29 -0500 (CDT)
Received: from hot.fatooh.org ([127.0.0.1])
	by localhost (hot.fatooh.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id U2WSA4JVFOIx for <netdev@vger.kernel.org>;
	Sat, 25 Aug 2007 17:30:29 -0500 (CDT)
Received: from bugfood (c-76-102-59-34.hsd1.ca.comcast.net [76.102.59.34])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by hot.fatooh.org (Postfix) with ESMTP id A1B2617C212
	for <netdev@vger.kernel.org>; Sat, 25 Aug 2007 17:30:29 -0500 (CDT)
In-Reply-To: 11880808243166-git-send-email-bugfood-ml@fatooh.org
References: 11880808243166-git-send-email-bugfood-ml@fatooh.org
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

