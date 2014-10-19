From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: Fw: [Bug 86531] New: Kernel panic when using nmap
Date: Sun, 19 Oct 2014 18:52:00 +0200
Message-ID: <CAADnVQ+WLjvdSha0_ooMDyfGOgwjtvaNcyCDzcW0rSMM44JkNg@mail.gmail.com>
References: <20141019221149.2b590638@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:38265 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751879AbaJSQwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Oct 2014 12:52:01 -0400
Received: by mail-qc0-f175.google.com with SMTP id b13so3012351qcw.34
        for <netdev@vger.kernel.org>; Sun, 19 Oct 2014 09:52:00 -0700 (PDT)
In-Reply-To: <20141019221149.2b590638@uryu.home.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 19, 2014 at 6:41 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
>
>
> Begin forwarded message:
>
> Date: Sun, 19 Oct 2014 08:02:37 -0700
> From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
> To: "stephen@networkplumber.org" <stephen@networkplumber.org>
> Subject: [Bug 86531] New: Kernel panic when using nmap
>
>
> https://bugzilla.kernel.org/show_bug.cgi?id=86531
>
>             Bug ID: 86531
>            Summary: Kernel panic when using nmap
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 3.17.1
>           Hardware: x86-64
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>           Assignee: shemminger@linux-foundation.org
>           Reporter: alxchk@gmail.com
>         Regression: No
>
> Created attachment 154181
>   --> https://bugzilla.kernel.org/attachment.cgi?id=154181&action=edit
> Crash log #1
>
> Strange crash appears the second time this day for me, when I starting nmap for
> scanning. Couldn't find any dependency. Anyway, dumps attached.

that's fixed in net tree and already in Linus's as well:
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=e0ee9c12157dc74e49e4731e0d07512e7d1ceb95
