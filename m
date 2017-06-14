From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH iproute/master 2/3] iptunnel: add support for mpls/ip to
 sit tunnels
Date: Wed, 14 Jun 2017 11:16:20 -0600
Message-ID: <eed46e61-80d0-4c7e-86c7-dc619b849ad8@gmail.com>
References: <1497058292-10099-1-git-send-email-kjlx@templeofstupid.com>
 <1497058292-10099-3-git-send-email-kjlx@templeofstupid.com>
 <20170614100211.1346dc4e@xeon-e3> <20170614171119.GB2368@templeofstupid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, simon.horman@netronome.com
To: Krister Johansen <kjlx@templeofstupid.com>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34936 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752141AbdFNRQX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 13:16:23 -0400
Received: by mail-pg0-f66.google.com with SMTP id f127so839160pgc.2
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 10:16:23 -0700 (PDT)
In-Reply-To: <20170614171119.GB2368@templeofstupid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/14/17 11:11 AM, Krister Johansen wrote:
> I did try to fix this up as part of bringing this patch up to date,
> since it was one of the concerns that David raised too.  I believe the
> problem that I ran into was that IPPROTO_MPLS wasn't defined in all
> versions of the headers where I tried to include them, and by bringing
> in in.h, I also managed to get a bunch of errors around re-definition of
> other symbols.
> 
> That said, I don't believe that 137 as the IPPROTO_MPLS value should
> change anytime soon.  It's defined in RFC 4023.
> 
> 	https://tools.ietf.org/html/rfc4023
> 
> However, if this is still seems problematic, I can take another shot at
> attempting to clean this up further.

IPPROTO_MPLS is defined in include/linux/in.h in iproute2.
