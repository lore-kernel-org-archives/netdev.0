From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v2] ipaddress: Fix segfault in 'addr showdump'
Date: Wed, 20 Sep 2017 17:54:02 -0700
Message-ID: <20170920175402.208117a7@xeon-e3>
References: <20170913092034.7002-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Hangbin Liu <liuhangbin@gmail.com>, netdev@vger.kernel.org,
        Julien Fortin <julien@cumulusnetworks.com>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:45126 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752115AbdIUAyF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 20:54:05 -0400
Received: by mail-pf0-f173.google.com with SMTP id z84so2394865pfi.2
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 17:54:05 -0700 (PDT)
In-Reply-To: <20170913092034.7002-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Sep 2017 11:20:34 +0200
Phil Sutter <phil@nwl.cc> wrote:

> Obviously, 'addr showdump' feature wasn't adjusted to json output
> support. As a consequence, calls to print_string() in print_addrinfo()
> tried to dereference a NULL FILE pointer.
> 
> Cc: Julien Fortin <julien@cumulusnetworks.com>
> Fixes: d0e720111aad2 ("ip: ipaddress.c: add support for json output")
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> --
> Changes since v1:
> Align json output with that of 'ip -j addr show':
> - Interface index label is 'ifindex', not 'index' and it doesn't belong
>   to 'addr_info' array.
> - Create one 'addr_info' array per dumped address, not one for all.
> ---
>  ip/ipaddress.c | 20 ++++++++++++++++++--
>  1 file changed, 18 insertions(+), 2 deletions(-)
> 

Looks good, applied.
