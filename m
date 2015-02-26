From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: [Bug 93901] New: TCP Fast Open uses
Date: Thu, 26 Feb 2015 08:13:23 -0800
Message-ID: <1424967203.5565.164.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150226080729.4c567be9@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	rueth@comsys.rwth-aachen.de
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:45110 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754564AbbBZQNZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 11:13:25 -0500
Received: by iecat20 with SMTP id at20so17142499iec.12
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 08:13:25 -0800 (PST)
In-Reply-To: <20150226080729.4c567be9@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-02-26 at 08:07 -0800, Stephen Hemminger wrote:
> 
> Begin forwarded message:
> 
> Date: Thu, 26 Feb 2015 15:43:45 +0000
> From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
> To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
> Subject: [Bug 93901] New: TCP Fast Open uses
> 
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=93901
> 
>             Bug ID: 93901
>            Summary: TCP Fast Open uses
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 4.0-rc1
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: low
>           Priority: P1
>          Component: IPV4
>           Assignee: shemminger@linux-foundation.org
>           Reporter: rueth@comsys.rwth-aachen.de
>         Regression: No
> 
> TCP Fast Open still uses the TCP Experimental Option even though RFC7413
> advises not to use the experimental options field anymore but rather use IANA
> assigned option number 34 (https://tools.ietf.org/html/rfc7413#section-9).

This is work in progress at Google, of course.

Classic chicken and egg problem ;)

Thanks
