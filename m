From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH] debugfs: improve formatting of debugfs_real_fops()
Date: Tue, 29 Nov 2016 12:11:37 -0800
Message-ID: <CAJpBn1xRuJYfDewZhOs4GvGpXKxndL+ux5c69ACA4Y4RS+X8kA@mail.gmail.com>
References: <1478798629-22318-1-git-send-email-jakub.kicinski@netronome.com> <20161129195805.GA2180@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Nicolai Stange <nicstange@gmail.com>,
        Christian Lamparter <chunkeey@gmail.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f181.google.com ([209.85.216.181]:34600 "EHLO
        mail-qt0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932359AbcK2ULi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 15:11:38 -0500
Received: by mail-qt0-f181.google.com with SMTP id n6so167331195qtd.1
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 12:11:38 -0800 (PST)
In-Reply-To: <20161129195805.GA2180@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 11:58 AM, Greg Kroah-Hartman
<gregkh@linuxfoundation.org> wrote:
> On Thu, Nov 10, 2016 at 05:23:49PM +0000, Jakub Kicinski wrote:
>> Type of debugfs_real_fops() is longer than parameters and
>> the name, so there is no way to break the declaration nicely.
>> We have to go over 80 characters.
>>
>> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
>> ---
>>  include/linux/debugfs.h | 3 +--
>>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> Doesn't apply to my tree, what did you make this against?

net-next, sorry, it

Fixes: 68f929ff2654 ("debugfs: constify argument to debugfs_real_fops()")

I think that change still haven't propagated out of Dave's tree.  Dave
didn't take my fix up patch, though, so my plan was to resend it to
you during the merge window?  Would that make sense?
