From: Joe Stringer <joe@ovn.org>
Subject: Re: [RFC net-next sample action optimization 1/3] openvswitch:
 deferred fifo api change
Date: Thu, 9 Mar 2017 11:08:34 -0800
Message-ID: <CAPWQB7GyKezwgjkGs3bm3W_cXMkGyy=5bW_xMpcB8Wb7kZh0nQ@mail.gmail.com>
References: <1488932137-120383-1-git-send-email-azhou@ovn.org> <1488932137-120383-2-git-send-email-azhou@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, pravin shelar <pshelar@ovn.org>
To: Andy Zhou <azhou@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:49308 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752450AbdCITI7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 14:08:59 -0500
Received: from mfilter6-d.gandi.net (mfilter6-d.gandi.net [217.70.178.135])
        by relay3-d.mail.gandi.net (Postfix) with ESMTP id C2ADEA80DC
        for <netdev@vger.kernel.org>; Thu,  9 Mar 2017 20:08:57 +0100 (CET)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
        by mfilter6-d.gandi.net (mfilter6-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 9yRHlxAPoPdv for <netdev@vger.kernel.org>;
        Thu,  9 Mar 2017 20:08:56 +0100 (CET)
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
        (Authenticated sender: joe@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 2FA79A80F1
        for <netdev@vger.kernel.org>; Thu,  9 Mar 2017 20:08:56 +0100 (CET)
Received: by mail-qk0-f176.google.com with SMTP id 1so134251098qkl.3
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 11:08:56 -0800 (PST)
In-Reply-To: <1488932137-120383-2-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7 March 2017 at 16:15, Andy Zhou <azhou@ovn.org> wrote:
> add_deferred_actions() API currently requires actions to be passed in
> as a fully encoded netlink message. So far both 'sample' and 'recirc'
> actions happens to carry actions as fully encoded netlink messages.
> However, this requirement is more restrictive than necessary, future
> patch will need to pass in action lists that are not fully encoded
> by themselves.
>
> Signed-off-by: Andy Zhou <azhou@ovn.org>

Acked-by: Joe Stringer <joe@ovn.org>
