From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH] netns: avoid disabling irq for netns id
Date: Tue, 29 Nov 2016 17:14:43 -0500
Message-ID: <CAGH-KgsK=Dc=Ptfg8P39pemFAsxVr9NKccev7sOW=w1suqKk+w@mail.gmail.com>
References: <148045748887.22539.3188295553967836703.stgit@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org, linux-audit@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:36389 "EHLO
        mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752526AbcK2WOp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 17:14:45 -0500
Received: by mail-oi0-f47.google.com with SMTP id v84so207871455oie.3
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 14:14:44 -0800 (PST)
In-Reply-To: <148045748887.22539.3188295553967836703.stgit@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 5:11 PM, Paul Moore <pmoore@redhat.com> wrote:
> From: Paul Moore <paul@paul-moore.com>
>
> Bring back commit bc51dddf98c9 ("netns: avoid disabling irq for netns
> id") now that we've fixed some audit multicast issues that caused
> problems with original attempt.  Additional information, and history,
> can be found in the links below:
>
>  * https://github.com/linux-audit/audit-kernel/issues/22
>  * https://github.com/linux-audit/audit-kernel/issues/23
>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Paul Moore <paul@paul-moore.com>
> ---
>  net/core/net_namespace.c |   35 +++++++++++++++--------------------
>  1 file changed, 15 insertions(+), 20 deletions(-)

Cong Wang, I added your sign-off to the patch since you were the
original author, if you would prefer I leave it off or want it changed
just let me know.

David/netdev, since this depends on a bunch of audit changes (about
nine patches) I went ahead and just merged this into the audit#next
branch.  If you have a problem with that let me know.

-- 
paul moore
security @ redhat
