From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] netns: revert "netns: avoid disabling irq for netns id"
Date: Fri, 21 Oct 2016 20:38:24 -0700
Message-ID: <CAM_iQpXd=8nHeCVKx4a5kBNf0mGb88i5eL=8+oaZcK-wKGVsXg@mail.gmail.com>
References: <147710095406.17836.12069093425270216381.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Elad Raz <e@eladraz.com>, Stephen Smalley <sds@tycho.nsa.gov>
To: Paul Moore <pmoore@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:37648 "EHLO
        mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932731AbcJVDip (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 23:38:45 -0400
Received: by mail-it0-f42.google.com with SMTP id m138so28133949itm.0
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 20:38:45 -0700 (PDT)
In-Reply-To: <147710095406.17836.12069093425270216381.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 21, 2016 at 6:49 PM, Paul Moore <pmoore@redhat.com> wrote:
> Eventually we should be able to reintroduce this code once we have
> rewritten the audit multicast code to queue messages much the same
> way we do for unicast messages.  A tracking issue for this can be
> found below:

NAK.

1) This will be forgotten by Paul.
2) There is already a fix which is considered as a rework by Paul.
3) -rc2 is Paul's personal deadline, not ours.
