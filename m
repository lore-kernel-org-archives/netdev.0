From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH 0/3] improve MACsec support
Date: Thu, 1 Sep 2016 09:12:36 -0700
Message-ID: <20160901091236.69fd83dd@xeon-e3>
References: <cover.1469520298.git.dcaratti@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemming@brocade.com>,
        Phil Sutter <phil@nwl.cc>,
        Sabrina Dubroca <sd@queasysnail.net>, netdev@vger.kernel.org
To: Davide Caratti <dcaratti@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36163 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933169AbcIAQM1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 12:12:27 -0400
Received: by mail-pf0-f169.google.com with SMTP id h186so32735031pfg.3
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 09:12:26 -0700 (PDT)
In-Reply-To: <cover.1469520298.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Jul 2016 11:03:17 +0200
Davide Caratti <dcaratti@redhat.com> wrote:

> parsing of 'cipher' and 'icvlen' arguments has been improved; while at it,
> a couple of missing printouts have been added to usage() functions in 
> "ip addr help" and "ip link help". Finally, some errors in the man pages
> have been fixed.
> 
> Signed-off-by: Davide Caratti <dcaratti@redhat.com>
> 
> Davide Caratti (3):
>   man: macsec: fix macsec related typos
>   ip {link,address}: add 'macsec' item to TYPE list
>   macsec: cipher and icvlen can be set separately
> 
>  ip/ipaddress.c           |  2 +-
>  ip/iplink.c              |  2 +-
>  ip/ipmacsec.c            | 52 ++++++++++++++++--------------------------------
>  man/man8/ip-address.8.in |  3 ++-
>  man/man8/ip-link.8.in    | 17 +++++++++++-----
>  man/man8/ip-macsec.8     | 13 ++++++++----
>  6 files changed, 42 insertions(+), 47 deletions(-)
> 

Applied
