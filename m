From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [RFC PATCH] net: diag: support SOCK_DESTROY for UDP sockets
Date: Fri, 19 Aug 2016 09:03:57 -0600
Message-ID: <e4c7c9f7-1d51-30d6-b073-f66057c1bc2a@cumulusnetworks.com>
References: <1471573759-23145-1-git-send-email-dsa@cumulusnetworks.com>
 <1471580259.29842.96.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33464 "EHLO
        mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754226AbcHSPEw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 11:04:52 -0400
Received: by mail-pa0-f42.google.com with SMTP id ti13so17033059pac.0
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 08:04:03 -0700 (PDT)
In-Reply-To: <1471580259.29842.96.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/18/16 10:17 PM, Eric Dumazet wrote:
> Why are you iterating the whole table ?
> 
> Normally, udp_hashfn(net, ntohs(dport), udptable->mask) slot should be
> enough to find all sockets bound to dport.

I took a tangent after in early mistake with the socket lookup and after that I was focused on doing the right thing in udp_abort and did not revisit the socket lookup. Reverted to __udp{4,6}_lib_lookup.
