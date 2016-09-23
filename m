From: Lance Richardson <lrichard@redhat.com>
Subject: Re: [PATCH net] ip6_gre: fix flowi6_proto value in
 ip6gre_xmit_other()
Date: Fri, 23 Sep 2016 15:52:24 -0400 (EDT)
Message-ID: <745948754.3473250.1474660344493.JavaMail.zimbra@redhat.com>
References: <1474649699-31069-1-git-send-email-lrichard@redhat.com> <20160923220036.55d469b0@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3-phx2.redhat.com ([209.132.183.24]:51885 "EHLO
        mx3-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753235AbcIWTw0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 15:52:26 -0400
In-Reply-To: <20160923220036.55d469b0@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: "Shmulik Ladkani" <shmulik.ladkani@gmail.com>
> To: "Lance Richardson" <lrichard@redhat.com>
> Cc: netdev@vger.kernel.org
> Sent: Friday, September 23, 2016 3:00:36 PM
> Subject: Re: [PATCH net] ip6_gre: fix flowi6_proto value in ip6gre_xmit_other()
> 
> On Fri, 23 Sep 2016 12:54:59 -0400 Lance Richardson <lrichard@redhat.com>
> wrote:
> > Similar to commit 3be07244b733 ("ip6_gre: fix flowi6_proto value in
> > xmit path"), set flowi6_proto to IPPROTO_GRE for output route lookup.
> 
> Suggesting to add:
> 
> Up until now, 'ip6gre_xmit_other' has set flowi6_proto to a bogus value.
> This affects output route lookup upon xmit of non ipv4/ipv6 packets on a
> ip6gretap device, in cases where routing depends on flowi6_proto.
> 

Added in v2, taking some editorial license (please let me know if I mangled it
too badly).

Thanks,

   Lance

> > Since the correct proto is already set in the tunnel flowi6 template via
> > commit 252f3f5a1189 ("ip6_gre: Set flowi6_proto as IPPROTO_GRE in xmit
> > path."), simply delete the line setting the incorrect flowi6_proto value.
> > 
> > Suggested-by: Jiri Benc <jbenc@redhat.com>
> > Fixes: commit c12b395a4664 ("gre: Support GRE over IPv6")
> > Signed-off-by: Lance Richardson <lrichard@redhat.com>
> 
> Reviewed-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> 
