From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: Linux XIA - merge proposal
Date: Tue, 10 Mar 2015 12:01:34 -0500
Message-ID: <CAErSpo6hUHYXrdB0+1WysD=AMuX3eawqSokTngR4s2tmmuakqA@mail.gmail.com>
References: <54F5EF6E.9090303@digirati.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Michel Machado <michel@digirati.com.br>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:39810 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752278AbbCJRBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 13:01:55 -0400
Received: by qcvs11 with SMTP id s11so3484753qcv.6
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2015 10:01:55 -0700 (PDT)
In-Reply-To: <54F5EF6E.9090303@digirati.com.br>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 3, 2015 at 11:29 AM, Michel Machado <michel@digirati.com.br> wrote:
> Hi there,
>
>    We have been developing Linux XIA, a new network stack that emphasizes
> evolvability and interoperability, for a couple of years, and it has now
> reached a degree of maturity that allows others to experiment with it.  In
> addition to the kernel implementation, we have a userland tool to set up the
> stack, a Wireshark fork with extensions for XIA packets, an implemented
> solution to interoperate with IPv4 networks, forwarding performance
> evaluation of our code, support for Linux containers, and an exemplifying
> demo; all documented on our wiki [1]. Outlining the full benefits of XIA
> goes beyond the scope of this e-mail, but we present an in-depth discussion
> on our wiki and in our peer-reviewed academic publications referenced there.
>
>    Linux XIA is not yet mature enough for production, but we do think that
> broader exposure will help us to move forward faster, and get more in tune
> with the interested community. Thus, we are writing to ask to merge our work
> into the Linux kernel.
>
>    We are aware of all of the effort required to review a large chunk of
> code, so to lower this burden, we propose to merge our new network stack via
> staging. This would give time for the community at large to get acquainted
> with XIA's concepts, and review the code. Of course, we will address
> feedback as it comes in. We're aware that the current Linux staging process
> [2] is geared toward drivers and filesystems, but not network stacks. We're
> fine with clearly marking Linux XIA as being under staging as well as
> helping to define this review process for network stacks.
>
>    Linux XIA is highly confined in its folder net/xia. There are a few
> headers in folder include/net, but all the names of these headers are of the
> form xia_*.h. Patches outside these files are minimal. This high isolation
> is a guarantee that Linux XIA can be dropped out of the kernel with little
> work if needed.
>
>    Finally, there are several other research groups around the world working
> on other future Internet architectures.  We hope that the process of merging
> Linux XIA will provide a template for these other groups to merge their
> network stacks into Linux in the future.

>From my point of view (far outside the networking world and completely
incompetent to judge the merits of XIA), this email seems like a
reasonable starting point for a discussion, and I'm disappointed that
it got shut down so fast.  It might not be in *exactly* the form
people are looking for, but hey, it's an introductory email, and
Michel seems open to constructive feedback.

Bjorn
