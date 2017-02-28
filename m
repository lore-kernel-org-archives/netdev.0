From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: net/rds: use-after-free in inet_create
Date: Tue, 28 Feb 2017 16:06:23 -0500
Message-ID: <20170228210623.GA28302@oracle.com>
References: <CACT4Y+bi=rZr9yrajA0o0iUeR4N0q-sXYudBVsOeOiHbuApBeA@mail.gmail.com>
 <20170228153737.GG31155@oracle.com>
 <CACT4Y+aobp+g_AYoX6j1eftyyirK4pBxhOXz9hDu+XU+-jxSYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: syzkaller <syzkaller@googlegroups.com>, netdev@vger.kernel.org
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1050.oracle.com ([156.151.31.82]:24440 "EHLO
        userp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751508AbdB1VIV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 16:08:21 -0500
Received: from userp1040.oracle.com (userp1040.oracle.com [156.151.31.81])
        by userp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v1SL7Zjo013096
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2017 21:07:35 GMT
Content-Disposition: inline
In-Reply-To: <CACT4Y+aobp+g_AYoX6j1eftyyirK4pBxhOXz9hDu+XU+-jxSYw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just posted an RFC patch, that I'm also testing here..
hopefully we'll se the pr_info light up, and know that the problematic
situation actually happened (I'll remove the pr_info if/when this
gets submitted as a non-RFC patch).. thanks for helping with testing
this..

--Sowmini
