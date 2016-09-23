From: Lance Richardson <lrichard@redhat.com>
Subject: Re: [PATCH net v2] ip6_gre: fix flowi6_proto value in
 ip6gre_xmit_other()
Date: Fri, 23 Sep 2016 16:37:38 -0400 (EDT)
Message-ID: <1901792360.3490653.1474663058137.JavaMail.zimbra@redhat.com>
References: <1474660229-5665-1-git-send-email-lrichard@redhat.com> <53fca902-c7e6-c216-6366-ba3f483854a0@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        shmulik ladkani <shmulik.ladkani@gmail.com>, jbenc@redhat.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:56979 "EHLO
        mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761323AbcIWUhk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 16:37:40 -0400
In-Reply-To: <53fca902-c7e6-c216-6366-ba3f483854a0@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: "Sergei Shtylyov" <sergei.shtylyov@cogentembedded.com>
> To: "Lance Richardson" <lrichard@redhat.com>, netdev@vger.kernel.org
> Cc: "shmulik ladkani" <shmulik.ladkani@gmail.com>, jbenc@redhat.com
> Sent: Friday, September 23, 2016 4:01:15 PM
> Subject: Re: [PATCH net v2] ip6_gre: fix flowi6_proto value in ip6gre_xmit_other()
> 
> Hello.
> 
> On 09/23/2016 10:50 PM, Lance Richardson wrote:
> 
> > Similar to commit 3be07244b733 ("ip6_gre: fix flowi6_proto value in
> > xmit path"), set flowi6_proto to IPPROTO_GRE for output route lookup.
> >
> > Up until now, ip6gre_xmit_other() has set flowi6_proto to a bogus value.
> > This affected output route lookup for packets sent on an ip6gretap device
> > in cases where routing was dependent on the value of flowi6_proto.
> >
> > Since the correct proto is already set in the tunnel flowi6 template via
> > commit 252f3f5a1189 ("ip6_gre: Set flowi6_proto as IPPROTO_GRE in xmit
> > path."), simply delete the line setting the incorrect flowi6_proto value.
> >
> > Suggested-by: Jiri Benc <jbenc@redhat.com>
> > Fixes: commit c12b395a4664 ("gre: Support GRE over IPv6")
> 
>     That "commit" isn't needed here, this tag has a standardized format.
> Hopefully, can be fixed while applying...

Thanks for pointing that out, I mistakenly added that "commit" after
checkpatch.pl complained about not having "commit" before the hashes
in the log. Hoping it can be fixed when applying as well.

> 
> > Reviewed-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> > Signed-off-by: Lance Richardson <lrichard@redhat.com>
> [...]
> 
> MBR, Sergei
> 
> 
