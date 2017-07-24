From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] ipv6: no need to return rt->dst.error if it is not
 null entry.
Date: Mon, 24 Jul 2017 12:57:43 -0700
Message-ID: <CAM_iQpW4qj2N77QrCvt9jd6jhOGvyRye8eyBzzk+vXeUi_FaoQ@mail.gmail.com>
References: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
 <CAPwn2JQHyj5gxqTFcJ-u9ABe544ivTBWskQfMgk2a2NirCF5rg@mail.gmail.com>
 <CAPwn2JTF+j84+Bv4Zn=pqju2tnMuuJrhTr9Un786-PZ0D6af3w@mail.gmail.com>
 <CAM_iQpUM6m=GvUU0OfwZAFsOGsf1UZmTjmuM9FH2P1iOZP=Svw@mail.gmail.com> <20170724030907.GC2938@leo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: network dev <netdev@vger.kernel.org>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:36244 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752087AbdGXT6F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 15:58:05 -0400
Received: by mail-wm0-f52.google.com with SMTP id t201so28325095wmt.1
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 12:58:04 -0700 (PDT)
In-Reply-To: <20170724030907.GC2938@leo.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 23, 2017 at 8:09 PM, Hangbin Liu <liuhangbin@gmail.com> wrote:
> Do we still need this net->ipv6.ip6_null_entry check? How about remove all
> the checks?

I believe you only need to check for rt->dst.error, no need to check against
NULL or ip6_null_entry.

Take a look at other ip6_route_lookup() callers.
