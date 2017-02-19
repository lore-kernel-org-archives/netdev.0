From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 iproute2 2/2] actions: Add support for user cookies
Date: Sat, 18 Feb 2017 16:24:17 -0800
Message-ID: <20170218162417.448989e8@xeon-e3>
References: <1486725944-16898-1-git-send-email-jhs@emojatatu.com>
        <1486725944-16898-2-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mrv@mojatatu.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:34305 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750812AbdBSAYT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Feb 2017 19:24:19 -0500
Received: by mail-pg0-f46.google.com with SMTP id z67so25488975pgb.1
        for <netdev@vger.kernel.org>; Sat, 18 Feb 2017 16:24:19 -0800 (PST)
In-Reply-To: <1486725944-16898-2-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 10 Feb 2017 06:25:44 -0500
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> Make use of 128b user cookies
> 
> Introduce optional 128-bit action cookie.
> Like all other cookie schemes in the networking world (eg in protocols
> like http or existing kernel fib protocol field, etc) the idea is to
> save user state that when retrieved serves as a correlator. The kernel
> _should not_ intepret it. The user can store whatever they wish in the
> 128 bits.

The support for this has not been accepted upstream in net-next yet.
Therefore submitting it into iproute2 is premature.
Pleas resubmit when the kernel part (and uapi) are upstream.
