From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_unix: Use designated initializers
Date: Thu, 06 Apr 2017 12:43:22 -0700 (PDT)
Message-ID: <20170406.124322.1591501459484458317.davem@davemloft.net>
References: <20170405051209.GA15324@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, mszeredi@redhat.com,
        viro@zeniv.linux.org.uk, xiyou.wangcong@gmail.com,
        hannes@stressinduktion.org, vdavydov.dev@gmail.com,
        avagin@openvz.org, netdev@vger.kernel.org
To: keescook@chromium.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37062 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751301AbdDFTnZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 15:43:25 -0400
In-Reply-To: <20170405051209.GA15324@beast>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kees Cook <keescook@chromium.org>
Date: Tue, 4 Apr 2017 22:12:09 -0700

> Prepare to mark sensitive kernel structures for randomization by making
> sure they're using designated initializers. These were identified during
> allyesconfig builds of x86, arm, and arm64, and the initializer fixes
> were extracted from grsecurity. In this case, NULL initialize with { }
> instead of undesignated NULLs.
> 
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied to net-next.
