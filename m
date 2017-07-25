From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net] ipv6: no need to return rt->dst.error if it is not
 null entry.
Date: Mon, 24 Jul 2017 21:28:07 -0600
Message-ID: <01b1cd24-ab81-3276-f253-70eef20e550b@gmail.com>
References: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
 <CAPwn2JQHyj5gxqTFcJ-u9ABe544ivTBWskQfMgk2a2NirCF5rg@mail.gmail.com>
 <CAPwn2JTF+j84+Bv4Zn=pqju2tnMuuJrhTr9Un786-PZ0D6af3w@mail.gmail.com>
 <CAM_iQpUM6m=GvUU0OfwZAFsOGsf1UZmTjmuM9FH2P1iOZP=Svw@mail.gmail.com>
 <20170724030907.GC2938@leo.usersys.redhat.com>
 <CAM_iQpW4qj2N77QrCvt9jd6jhOGvyRye8eyBzzk+vXeUi_FaoQ@mail.gmail.com>
 <20170725000849.GD2938@leo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: network dev <netdev@vger.kernel.org>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
To: Hangbin Liu <liuhangbin@gmail.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:36375 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753468AbdGYD2K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 23:28:10 -0400
Received: by mail-pg0-f48.google.com with SMTP id 125so65068965pgi.3
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 20:28:10 -0700 (PDT)
In-Reply-To: <20170725000849.GD2938@leo.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/24/17 6:08 PM, Hangbin Liu wrote:
> That's why I think we should remove both rt->dst.error and ip6_null_entry
> check in inet6_rtm_getroute(). And even further, remove the ip6_null_entry
> check in rt6_dump_route().

git blame net/ipv6/route.c

find the commits and review.
