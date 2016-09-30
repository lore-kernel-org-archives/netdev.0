From: Greg <gvrose8192@gmail.com>
Subject: Re: [PATCH 0/7] ethtool: misc fixes for Coverity issues
Date: Fri, 30 Sep 2016 13:26:04 -0700
Message-ID: <1475267164.3279.4.camel@gmail.com>
References: <1475265381-28937-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33591 "EHLO
        mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750703AbcI3U0G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 16:26:06 -0400
Received: by mail-pa0-f43.google.com with SMTP id cd13so38430399pac.0
        for <netdev@vger.kernel.org>; Fri, 30 Sep 2016 13:26:06 -0700 (PDT)
In-Reply-To: <1475265381-28937-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-09-30 at 15:56 -0400, John W. Linville wrote:
> I requested a Coverity scan of the current ethtool sources. There
> weren't many issues identified, but it was non-zero.
> 
> Most/all of the resource leak issues can be explained away as
> unimportant due to the fact that ethtool invocations are short-term
> processes. Nevertheless, I prefer to have those issues "fixed" both
> to avoid them as distractions and just to promote better coding
> practices overall.

The patch series looks good to me.

Reviewed-by: Greg Rose <grose@lightfleet.com>

> 
> These are "fresh off the press" -- I'll re-review them again before
> applying and pushing them. I appreciate any extra eyeballs that can
> review them as well.
> 
> John
> --
> John W. Linville		Someday the world will need a hero, and you
> linville@tuxdriver.com			might be all we have.  Be ready.
> 
