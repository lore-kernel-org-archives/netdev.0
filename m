From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: net/rds: use-after-free in inet_create
Date: Tue, 28 Feb 2017 12:48:33 -0500
Message-ID: <20170228174833.GN31155@oracle.com>
References: <CACT4Y+bi=rZr9yrajA0o0iUeR4N0q-sXYudBVsOeOiHbuApBeA@mail.gmail.com>
 <20170228153737.GG31155@oracle.com>
 <CACT4Y+aobp+g_AYoX6j1eftyyirK4pBxhOXz9hDu+XU+-jxSYw@mail.gmail.com>
 <20170228161544.GH31155@oracle.com>
 <CACT4Y+bWWAiMYQN_Fvxs7CKR9hRAA+r0t_YZhja3B5xGcZ4vcQ@mail.gmail.com>
 <20170228163833.GI31155@oracle.com>
 <CACT4Y+Y5eM8hKQ7BgA4hEN7ozkhRGgvGJRU6Smrths6noC-PMw@mail.gmail.com>
 <20170228173328.GL31155@oracle.com>
 <CACT4Y+YFMORo6YJBG_wOCFPK4dHHzQ_fBp650-E3REH8SdwpAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: santosh.shilimkar@oracle.com, David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, linux-rdma@vger.kernel.org,
        rds-devel@oss.oracle.com, LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1050.oracle.com ([156.151.31.82]:46972 "EHLO
        userp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751334AbdB1Rwe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 12:52:34 -0500
Content-Disposition: inline
In-Reply-To: <CACT4Y+YFMORo6YJBG_wOCFPK4dHHzQ_fBp650-E3REH8SdwpAQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (02/28/17 18:45), Dmitry Vyukov wrote:
> 
> Yes, I can now apply custom patches to the bots. However, it fired
> only 3 times, so it will give weak signal. But at least it will test
> that the patch does not cause other bad things.

Ok, let me do my bit of homework on this one and get back to you
(probably by tomorrow)..
