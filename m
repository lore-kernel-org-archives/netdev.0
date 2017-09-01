From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH 0/2] Fix and enhance link_gre6
Date: Fri, 1 Sep 2017 12:10:33 -0700
Message-ID: <20170901121033.09e4e210@xeon-e3>
References: <20170901140809.13230-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34053 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752217AbdIATKg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 15:10:36 -0400
Received: by mail-pf0-f171.google.com with SMTP id l87so2978859pfj.1
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 12:10:36 -0700 (PDT)
In-Reply-To: <20170901140809.13230-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  1 Sep 2017 16:08:07 +0200
Phil Sutter <phil@nwl.cc> wrote:

> Changing a tunnel's flowlabel value was broken if it was set to a
> non-zero value before. Since the same problem existed for tclass, patch
> 1 fixes both instances at once.
> 
> Patch 2 enhances 'ip link show' to also print the tclass value. This
> change was necessary to properly test the first patch's result.
> 
> Phil Sutter (2):
>   link_gre6: Fix for changing tclass/flowlabel
>   link_gre6: Print the tunnel's tclass setting
> 
>  ip/link_gre6.c | 11 ++++++++++-
>  1 file changed, 10 insertions(+), 1 deletion(-)
> 

Applied, thanks.
