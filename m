From: Roman Mashak <mrv@mojatatu.com>
Subject: Re: [PATCH net-next 0/2] Fix IFE meta modules loading
Date: Thu, 12 Oct 2017 16:37:39 -0400
Message-ID: <85lgkgw19o.fsf@mojatatu.com>
References: <1507733430-17860-1-git-send-email-mrv@mojatatu.com>
        <20171012.122318.1151617277989957064.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:48271 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752756AbdJLUho (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 16:37:44 -0400
Received: by mail-it0-f46.google.com with SMTP id c3so8829756itc.3
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 13:37:43 -0700 (PDT)
In-Reply-To: <20171012.122318.1151617277989957064.davem@davemloft.net> (David
        Miller's message of "Thu, 12 Oct 2017 12:23:18 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Roman Mashak <mrv@mojatatu.com>
> Date: Wed, 11 Oct 2017 10:50:28 -0400
>
>> Adjust module alias names of IFE meta modules and fix the bug that
>> prevented auto-loading IFE modules in run-time.
>
> Anyone using the existing alises will be broken by these changes
> no?

Actually aliases never worked, the bug existed since the day act_meta_*
modules have been introduced. I suspect everyone compiles them in-kernel
rather then as modules.

> Is it possible to define multiple aliases?  That would be a way to
> get the more desirable names whilst not breaking existing users.
