From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH 0/5] sky2: Avoid memory allocations on suspend/resume
Date: Thu, 13 May 2010 08:16:15 +0900
Message-ID: <4BEB36BF.1050006@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:48719 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755771Ab0ELXZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 19:25:22 -0400
Received: by pwi5 with SMTP id 5so326811pwi.19
        for <netdev@vger.kernel.org>; Wed, 12 May 2010 16:25:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

This patch set rearranges sky2_suspend and sky2_resume so that we don't free memory and reallocate it when suspending.

Furthermore, there's two small fixes (Avoid race in sky2_change_mtu) for which I've clarified the commit message, and
(Restore multicast after restart) which restores the multicast settings after reset, as they may be lost.

thanks,

Mike
