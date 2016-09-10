From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v2] net: ip, diag -- Add diag interface for raw sockets
Date: Sat, 10 Sep 2016 16:28:40 -0600
Message-ID: <c5889fbd-ad20-0626-be1f-9d09a1d35b1a@cumulusnetworks.com>
References: <20160909182636.GC2366@uranus.lan>
 <de68cd54-849e-93d6-b291-83e8be010f9a@cumulusnetworks.com>
 <20160910220528.GB2001@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: NETDEV <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Andrey Vagin <avagin@openvz.org>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36675 "EHLO
        mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753887AbcIJW2p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Sep 2016 18:28:45 -0400
Received: by mail-pa0-f49.google.com with SMTP id id6so39287591pad.3
        for <netdev@vger.kernel.org>; Sat, 10 Sep 2016 15:28:45 -0700 (PDT)
In-Reply-To: <20160910220528.GB2001@uranus.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/10/16 4:05 PM, Cyrill Gorcunov wrote:
> On Sat, Sep 10, 2016 at 10:31:35AM -0600, David Ahern wrote:
>>
>> Would you mind adding the destroy capability as well? The udp version
>> should be close to what is needed for raw sockets. See udp_diag_destroy
>> and udp_abort.
> 
> Should be something like below. Didn't tested it yet so for review only.
> Will do testing at Monday.

doesn't compile:
- raw_abort needs to be in a header for ipv6, and
- inet_sk_diag_fill args have changed due to a recent commit
