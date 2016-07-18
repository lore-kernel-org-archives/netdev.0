From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net] bnxt_en: Remove locking around txr->dev_state
Date: Mon, 18 Jul 2016 13:06:36 -0700
Message-ID: <CACKFLi=cZ4EZ8U2y2R5ZXur9q1_HFFDNpa99i2dhvmoxZSgneA@mail.gmail.com>
References: <1468626125-31732-1-git-send-email-f.fainelli@gmail.com> <1468872171-10009-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jeffrey Huang <huangjw@broadcom.com>,
	open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:33337 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751640AbcGRUGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 16:06:38 -0400
Received: by mail-oi0-f52.google.com with SMTP id j185so261795396oih.0
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 13:06:37 -0700 (PDT)
In-Reply-To: <1468872171-10009-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 18, 2016 at 1:02 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> txr->dev_state was not consistently manipulated with the acquisition of
> the per-queue lock, after further inspection the lock does not seem
> necessary, either the value is read as BNXT_DEV_STATE_CLOSING or 0.
>
> Reported-by: coverity (CID 1339583)
> Fixes: c0c050c58d840 ("bnxt_en: New Broadcom ethernet driver.")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks Florian.

Acked-by: Michael Chan <michael.chan@broadcom.com>
