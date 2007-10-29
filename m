From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [iproute2] SFQ: backport some features from ESFQ (try 5)
Date: Mon, 29 Oct 2007 00:24:44 -0700
Message-ID: <1193642687-1272-1-git-send-email-bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:50394 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751918AbXJ2HYt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 03:24:49 -0400
Received: from localhost (localhost [127.0.0.1])
	by hot.fatooh.org (Postfix) with ESMTP id DDF6917C255
	for <netdev@vger.kernel.org>; Mon, 29 Oct 2007 02:24:48 -0500 (CDT)
Received: from hot.fatooh.org ([127.0.0.1])
	by localhost (hot.fatooh.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 0hHPauWiAtsG for <netdev@vger.kernel.org>;
	Mon, 29 Oct 2007 02:24:48 -0500 (CDT)
Received: from bugfood (c-24-7-71-25.hsd1.ca.comcast.net [24.7.71.25])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by hot.fatooh.org (Postfix) with ESMTP id 3DABD17C094
	for <netdev@vger.kernel.org>; Mon, 29 Oct 2007 02:24:48 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


These patches follow the ESFQ-->SFQ kernel patches. See the kernel
patch summary for general information.

Thanks,
Corey


 include/linux/pkt_sched.h |   23 ++++++++++++++---------
 tc/q_sfq.c                |   42 +++++++++++++++++++++++++++++++++++++-----
 2 files changed, 51 insertions(+), 14 deletions(-)


[PATCH 1/3] SFQ: Support changing depth and divisor.
[PATCH 2/3] Change perturb_period to unsigned.
[PATCH 3/3] Use nested compat attributes for passing parameters to the kernel.
