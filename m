From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net v2] ip6_gre: fix flowi6_proto value in
 ip6gre_xmit_other()
Date: Fri, 23 Sep 2016 23:01:15 +0300
Message-ID: <53fca902-c7e6-c216-6366-ba3f483854a0@cogentembedded.com>
References: <1474660229-5665-1-git-send-email-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shmulik.ladkani@gmail.com, jbenc@redhat.com
To: Lance Richardson <lrichard@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:36190 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753315AbcIWUBV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 16:01:21 -0400
Received: by mail-lf0-f47.google.com with SMTP id g62so100758354lfe.3
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 13:01:20 -0700 (PDT)
In-Reply-To: <1474660229-5665-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 09/23/2016 10:50 PM, Lance Richardson wrote:

> Similar to commit 3be07244b733 ("ip6_gre: fix flowi6_proto value in
> xmit path"), set flowi6_proto to IPPROTO_GRE for output route lookup.
>
> Up until now, ip6gre_xmit_other() has set flowi6_proto to a bogus value.
> This affected output route lookup for packets sent on an ip6gretap device
> in cases where routing was dependent on the value of flowi6_proto.
>
> Since the correct proto is already set in the tunnel flowi6 template via
> commit 252f3f5a1189 ("ip6_gre: Set flowi6_proto as IPPROTO_GRE in xmit
> path."), simply delete the line setting the incorrect flowi6_proto value.
>
> Suggested-by: Jiri Benc <jbenc@redhat.com>
> Fixes: commit c12b395a4664 ("gre: Support GRE over IPv6")

    That "commit" isn't needed here, this tag has a standardized format. 
Hopefully, can be fixed while applying...

> Reviewed-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> Signed-off-by: Lance Richardson <lrichard@redhat.com>
[...]

MBR, Sergei
