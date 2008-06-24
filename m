From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH] IRDA: Fix genlmsg_put() return value check.
Date: Tue, 24 Jun 2008 11:18:01 +0200
Message-ID: <f4845fc0806240218x978c7ceoe487734f9358fb54@mail.gmail.com>
References: <1214248629-6208-1-git-send-email-juliusv@google.com>
	 <485FFCE3.2050800@trash.net>
	 <f4845fc0806231329p7ef94a8dqafe63feea89ad949@mail.gmail.com>
	 <486037C7.6010409@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:7685 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239AbYFXJSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 05:18:13 -0400
Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id m5O9I3ek004275
	for <netdev@vger.kernel.org>; Tue, 24 Jun 2008 10:18:03 +0100
Received: from yx-out-1718.google.com (yxh36.prod.google.com [10.190.2.228])
	by zps75.corp.google.com with ESMTP id m5O9I2s0032287
	for <netdev@vger.kernel.org>; Tue, 24 Jun 2008 02:18:02 -0700
Received: by yx-out-1718.google.com with SMTP id 36so394047yxh.24
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2008 02:18:02 -0700 (PDT)
In-Reply-To: <486037C7.6010409@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 24, 2008, Patrick McHardy wrote:
> Yes, all those should be using ENOSPC as well. nl80211 returns
> inconsistent errors currently (-1/EMSGSIZE), but doesn't propagate
> them back to userspace. That should probably be fixed as well.
>
> Actually I was wrong, its EMSGSIZE, not ENOSPC that should be
> returned, its more fitting and what other netlink users do as
> well.

Thanks, I will use that then!

Julius

-- 
Google Switzerland GmbH
