From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net/rds: use-after-free in inet_create
Date: Wed, 1 Mar 2017 00:14:39 +0300
Message-ID: <CACT4Y+akanLaOw6M0=Q8kzrD9TTDUw1_J7kj-S7zUVgT_zMW+w@mail.gmail.com>
References: <CACT4Y+bi=rZr9yrajA0o0iUeR4N0q-sXYudBVsOeOiHbuApBeA@mail.gmail.com>
 <20170228153737.GG31155@oracle.com> <CACT4Y+aobp+g_AYoX6j1eftyyirK4pBxhOXz9hDu+XU+-jxSYw@mail.gmail.com>
 <20170228210623.GA28302@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>,
        netdev <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f180.google.com ([209.85.217.180]:35273 "EHLO
        mail-ua0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751450AbdB1VYW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 16:24:22 -0500
Received: by mail-ua0-f180.google.com with SMTP id 40so28703246uau.2
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2017 13:24:21 -0800 (PST)
In-Reply-To: <20170228210623.GA28302@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 1, 2017 at 12:06 AM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> Just posted an RFC patch, that I'm also testing here..
> hopefully we'll se the pr_info light up, and know that the problematic
> situation actually happened (I'll remove the pr_info if/when this
> gets submitted as a non-RFC patch).. thanks for helping with testing
> this..


But the other 2 use-after-frees happened on cp->cp_send_w. Shouldn't
we cancel it as well? And cp_recv_w?
