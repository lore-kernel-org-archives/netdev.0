From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net 3/3] team: use a larger struct for mac address
Date: Wed, 26 Apr 2017 09:11:35 -0700
Message-ID: <CAM_iQpVXBuXNfVM_h894HEF_9hv2rWgDJcMbvEJG25xfm7DGUA@mail.gmail.com>
References: <1493183003-884-1-git-send-email-xiyou.wangcong@gmail.com>
 <1493183003-884-4-git-send-email-xiyou.wangcong@gmail.com>
 <20170426054033.GA1867@nanopsycho.orion> <7103fb6b-2483-37c0-48e5-19aa9fd4f386@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>
To: Jarod Wilson <jarod@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37052 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750965AbdDZQL5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 12:11:57 -0400
Received: by mail-wm0-f43.google.com with SMTP id m123so9465515wma.0
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 09:11:56 -0700 (PDT)
In-Reply-To: <7103fb6b-2483-37c0-48e5-19aa9fd4f386@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 8:55 AM, Jarod Wilson <jarod@redhat.com> wrote:
>
> We already have struct sockaddr_storage that could be used throughout this
> set as well. We just converted a few pieces of the bonding driver over to
> using it for better support of ipoib bonds, via commit
> faeeb317a5615076dff1ff44b51e862e6064dbd0. Might be better to just use that
> in both bonding and team, rather than having different per-driver structs,
> or Yet Another Address Storage implementation.

Technically, struct sockaddr_storage is not enough either, given the
max is MAX_ADDR_LEN. This is why I gave up on sockaddr_storage.
