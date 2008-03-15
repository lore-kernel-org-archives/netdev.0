From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: Re: TCP stack optimization for high number of connections [OT]
Date: Sat, 15 Mar 2008 09:32:16 -0700
Message-ID: <2c0942db0803150932s6e654e28g5255ac7af451741b@mail.gmail.com>
References: <873209.1586.qm@web52510.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: "Marc Perkel" <mperkel@yahoo.com>, Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:46807 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907AbYCOQcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Mar 2008 12:32:18 -0400
Received: by fg-out-1718.google.com with SMTP id l27so767839fgb.17
        for <netdev@vger.kernel.org>; Sat, 15 Mar 2008 09:32:17 -0700 (PDT)
In-Reply-To: <873209.1586.qm@web52510.mail.re2.yahoo.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(CC:netdev added.)

On Sat, Mar 15, 2008 at 8:47 AM, Marc Perkel <mperkel@yahoo.com> wrote:
> I'm running a front end spam filtering service and I
>  get a lot of incoming connections but not a lot of
>  volume of traffic. I'm experiencing some high loads
>  and I think it might be related to the volume of
>  connections it's processing. I often will be connected
>  to 2500 email servers at once and a lot more that are
>  trying to connect and being denied.
>
>  My question - are there any optimizations I can do to
>  make the TCP faster for high number of short lived
>  connections?
>
>  Also - how much do iptable entries slow things down
>  and is there any optimizations for that?
>
>
>  Marc Perkel
>  Junk Email Filter dot com
>  http://www.junkemailfilter.com
