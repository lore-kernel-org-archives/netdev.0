From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC Patch net-next 0/6] net_sched: really switch to RCU for tc
 actions
Date: Fri, 2 Sep 2016 09:09:42 +0200
Message-ID: <20160902070942.GB2150@nanopsycho>
References: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33222 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751124AbcIBHJq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 03:09:46 -0400
Received: by mail-wm0-f68.google.com with SMTP id w207so1612610wmw.0
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 00:09:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Sep 02, 2016 at 07:57:14AM CEST, xiyou.wangcong@gmail.com wrote:
>Currently there are only two tc actions lockless:
>gact and mirred. But they are questionable because
>we don't have anything to prevent a parallel update
>on an existing tc action in hash table while reading
>it on fast path, this could be a problem when a tc
>action becomes complex.
>
>This patchset introduces a few new tc action API's
>based on RCU so that the fast path could now really
>be protected by RCU and we can update existing tc
>actions safely and race-freely.
>
>Obviously this is still _not_ complete yet, I only
>modified mirred action to show the use case of
>the new API's, all the rest actions could switch to
>the new API's too. The new API's are a bit ugly too,
>any suggestion to improve them is welcome.
>
>I tested mirred action with a few test cases, so far
>so good, at least no obvious bugs. ;)


I wonder, do you happen to have a very tiny narrow screen?
