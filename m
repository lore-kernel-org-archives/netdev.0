From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/1] ip: initialize FILE pointer in ip-monitor
Date: Wed, 27 Sep 2017 08:36:13 +0100
Message-ID: <20170927083613.3bf9754f@shemminger-XPS-13-9360>
References: <1506453236-7034-1-git-send-email-mrv@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:44037 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751396AbdI0HgS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 03:36:18 -0400
Received: by mail-wm0-f50.google.com with SMTP id m127so18890199wmm.1
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 00:36:17 -0700 (PDT)
In-Reply-To: <1506453236-7034-1-git-send-email-mrv@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Sep 2017 15:13:56 -0400
Roman Mashak <mrv@mojatatu.com> wrote:

> Since FILE *_fp was not explicitly initialized, all the consequent print_*()
> calls were failing.
> 
> Signed-off-by: Roman Mashak <mrv@mojatatu.com>

This works, but the later patch by Julien Fortien which gets rid of the
FILE * argument all together is a cleaner solution. I will skip this
patch and apply that one.
