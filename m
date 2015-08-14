From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: [Bug 102861] New: soft lockup with "inet: fix races with
 reqsk timers"
Date: Fri, 14 Aug 2015 09:17:03 -0700
Message-ID: <1439569023.7507.2.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150814085709.2348c2c1@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35044 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755113AbbHNQRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 12:17:06 -0400
Received: by pacgr6 with SMTP id gr6so62783491pac.2
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 09:17:05 -0700 (PDT)
In-Reply-To: <20150814085709.2348c2c1@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-08-14 at 08:57 -0700, Stephen Hemminger wrote:
> 
> Begin forwarded message:
> 
> Date: Fri, 14 Aug 2015 14:32:56 +0000
> From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
> To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
> Subject: [Bug 102861] New: soft lockup with "inet: fix races with reqsk timers"
> 
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=102861
> 
>             Bug ID: 102861
>            Summary: soft lockup with "inet: fix races with reqsk timers"
>            Product: Networking
>            Version: 2.5
>     Kernel Version: net-next d52736e2
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>           Assignee: shemminger@linux-foundation.org
>           Reporter: andreas.reis@gmail.com
>         Regression: No
> 
> Created attachment 184921
>   --> https://bugzilla.kernel.org/attachment.cgi?id=184921&action=edit
> dmesg picture
> 
> Happens withing 10min while eg. torrenting. net-next from a few days ago was
> fine.
> 
> Picture as ssh hangs and dmesg to disk lands in nirvana instead.
> 
> Checked via reverting this commit, which allowed me to merrily torrent without
> lockup again. This does not 100% prove that it was actually the cause, ofc.
> 

Fixed with :
http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=83fccfc3940c4a2db90fd7e7079f5b465cd8c6af
