From: "Rami Rosen" <roszenrami@gmail.com>
Subject: Re: 2.6.24-mm1 - Build failure at net/sched/cls_flow.c:598
Date: Tue, 5 Feb 2008 09:24:38 +0200
Message-ID: <b25312890802042324q272324ffo4157f873dd4f44a8@mail.gmail.com>
References: <20080203171634.58ab668b.akpm@linux-foundation.org>
	 <47A79291.5010204@imap.cc>
	 <20080204152505.62b2b8b5.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Tilman Schmidt" <tilman@imap.cc>, linux-kernel@vger.kernel.org,
	"Patrick McHardy" <kaber@trash.net>, netdev@vger.kernel.org
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu-out-0506.google.com ([72.14.214.233]:10226 "EHLO
	hu-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754924AbYBEHYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 02:24:40 -0500
Received: by hu-out-0506.google.com with SMTP id 19so2805342hue.21
        for <netdev@vger.kernel.org>; Mon, 04 Feb 2008 23:24:38 -0800 (PST)
In-Reply-To: <20080204152505.62b2b8b5.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
  I had sent a patch recently (which is currently pending) which
solves this problem.

see:
http://www.spinics.net/lists/netdev/msg54455.html


Regards,
Rami Rosen


On Feb 5, 2008 1:25 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Mon, 04 Feb 2008 23:32:49 +0100
> Tilman Schmidt <tilman@imap.cc> wrote:
>
> > My attempt to build this failed with:
> >
> >    CC [M]  net/sched/cls_flow.o
> > net/sched/cls_flow.c: In function ___flow_dump___:
> > net/sched/cls_flow.c:598: error: ___struct tcf_ematch_tree___ has no member named ___hdr___
> >
> > Config attached.
>
> Thanks.  hm.
>
>         #else /* CONFIG_NET_EMATCH */
>
>         struct tcf_ematch_tree
>         {
>         };
>
> methinks Patrick has a CONFIG_NET_EMATCH=n problem?
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
