From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: [PATCH net 0/3]tg3: synchronize_irq() should be called without
 taking locks
Date: Wed, 14 Jan 2015 10:57:50 -0500
Message-ID: <54B691FE.50903@hurleysoftware.com>
References: <1421217039-11689-1-git-send-email-prashant@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: Prashant Sreedharan <prashant@broadcom.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:52114 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753307AbbANP5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 10:57:52 -0500
Received: by mail-qg0-f42.google.com with SMTP id q108so7556191qgd.1
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 07:57:51 -0800 (PST)
In-Reply-To: <1421217039-11689-1-git-send-email-prashant@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/14/2015 01:30 AM, Prashant Sreedharan wrote:
> Prashant Sreedharan (3):
>   tg3_timer() should grab tp->lock before checking for tp->irq_sync
>   tg3_reset_task() needs to use rtnl_lock to synchronize
>   Release tp->lock before invoking synchronize_irq()

Thanks!

For series:

Reported-by: Peter Hurley <peter@hurleysoftware.com>
Tested-by: Peter Hurley <peter@hurleysoftware.com>

But maybe one of these patches should reference that this fixes
BUG: sleeping function... so that others can quickly find this
fix (if they're bisecting or whatever). For the same reason, it
might be useful for this series to be just one patch.

Regards,
Peter Hurley
