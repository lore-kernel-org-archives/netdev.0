From: Dave Taht <dave.taht@gmail.com>
Subject: Re: Adding new packet scheduler
Date: Mon, 20 Oct 2014 10:46:44 -0700
Message-ID: <CAA93jw5jHMeNcDHUO4ZG=__J8y_Gv1Ogv7+_q1ctdtpK-_nd_A@mail.gmail.com>
References: <CAHmvzZQALDuwMPZC_ZncEP=BerniYis9Mx=oObUGNAY4wUGTZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Josh Clark <jcinma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:63623 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180AbaJTRqo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2014 13:46:44 -0400
Received: by mail-oi0-f54.google.com with SMTP id v63so4091303oia.13
        for <netdev@vger.kernel.org>; Mon, 20 Oct 2014 10:46:44 -0700 (PDT)
In-Reply-To: <CAHmvzZQALDuwMPZC_ZncEP=BerniYis9Mx=oObUGNAY4wUGTZg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 20, 2014 at 10:32 AM, Josh Clark <jcinma@gmail.com> wrote:
> Hi everyone,
>
> I'm a student at NC State University, and I'm working on a project to
> implement some new classful AQM algorithms and test their
> effectiveness. However, I'm getting hung up on how to get the new
> algorithm set up in the kernel.
>
> From what I've looked at, it looks like I need to add my code to
> /net/sched/, and edit both the Kconfig and the Makefile to be able to
> add my code as another module.
>
> Finally, in order to use the new scheduler, I need to select it using
> the tc command. What do I need to do to add my algorithm to the tc
> command options?
>
> Any insight, articles, READMEs, or criticism you have for me is welco=
me.
>
> Thank you for all your help!

To give you an idea here are some currently out of tree, out of date,
and highly experimental codel patches of mine
that add in some new qdiscs, and patch the right places, with the
exception of patching include/uapi/linux/pkt_sched.h (which exports
the stuff to userspace)

https://github.com/dtaht/cerowrt-3.10/blob/master/target/linux/generic/=
patches-3.10/680-codel-add-experimental-codel-and-fq_codel-versions.pat=
ch

to add stuff to tc, you patch the iproute2 utility to match what is
exported from pkt_sched.h.




>
>
>
> -Josh Clark
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--=20
Dave T=C3=A4ht

thttp://www.bufferbloat.net/projects/bloat/wiki/Upcoming_Talks
