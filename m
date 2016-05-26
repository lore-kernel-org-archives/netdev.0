From: Timur Tabi <timur@codeaurora.org>
Subject: How can I test ndo_tx_timeout()?
Date: Thu, 26 May 2016 15:40:11 -0500
Message-ID: <CAOZdJXWDp1VzCtu0PQp9m_62_2sXLZeiZqsmqb_GP71Bn1bMuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:47831 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755145AbcEZUkN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 16:40:13 -0400
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: timur@smtp.codeaurora.org)
	by smtp.codeaurora.org (Postfix) with ESMTPSA id 1B9106135E
	for <netdev@vger.kernel.org>; Thu, 26 May 2016 20:40:11 +0000 (UTC)
Received: by mail-oi0-f54.google.com with SMTP id k23so143344937oih.0
        for <netdev@vger.kernel.org>; Thu, 26 May 2016 13:40:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is there an easy way to test my driver's response to a
ndo_tx_timeout() call?  That is, force dev_watchdog() to think that a
timeout has occurred?

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
a Linux Foundation Collaborative Project.
