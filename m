From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute/master 0/3] lost mpls ip tunnel patches
Date: Wed, 5 Jul 2017 09:06:50 -0700
Message-ID: <20170705090650.6598846d@xeon-e3>
References: <1497058292-10099-1-git-send-email-kjlx@templeofstupid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, simon.horman@netronome.com,
        dsahern@gmail.com
To: Krister Johansen <kjlx@templeofstupid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:36632 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751678AbdGEQG5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 12:06:57 -0400
Received: by mail-pg0-f48.google.com with SMTP id u62so126456813pgb.3
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2017 09:06:57 -0700 (PDT)
In-Reply-To: <1497058292-10099-1-git-send-email-kjlx@templeofstupid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  9 Jun 2017 18:31:29 -0700
Krister Johansen <kjlx@templeofstupid.com> wrote:

> Hi Stephen,
> I'm a bit unsure of the decorum in this particular situation. Kernel
> support for mpls/ip tunnels was integrated back in July of 2016.  At the
> time, the author of that feature sent out a RFC patch for the iproute
> support but never followed up on subsequent code review comments.
> 
> The kernel support got merged, but the iproute support never made it in.
> I wanted to run some tests with these features.  In the process, I
> tracked down the author's original patches, merged them into current
> iproute, and attempted to address the comments from code reviewers.
> 
> I've attached an 'Original-Author' label to each commit, and have CC'd
> him and the code reviewer on this patch.  If any part of this is
> improper, please let me know and I'll respin accordingly.  Mostly, I
> wanted to close the loop here so the mpls in ip tunnel support is usable
> through iproute.
> 
> The original threads for the 2016 patch are here:
> 
> http://marc.info/?l=linux-netdev&m=146782946216005&w=2
> http://marc.info/?l=linux-netdev&m=146782941615977&w=2
> http://marc.info/?l=linux-netdev&m=146782947016007&w=2
> http://marc.info/?l=linux-netdev&m=146782942915988&w=2
> 
> Thanks,
> 
> -K
> 
> Krister Johansen (3):
>   iptunnel: document mode parameter for sit tunnels
>   iptunnel: add support for mpls/ip to sit tunnels
>   iptunnel: add support for mpls/ip to ipip tunnels
> 
>  include/utils.h       |  3 +++
>  ip/link_iptnl.c       | 30 ++++++++++++++++++++++++++----
>  ip/tunnel.c           |  3 +++
>  man/man8/ip-link.8.in | 12 +++++++++++-
>  4 files changed, 43 insertions(+), 5 deletions(-)
> 

I went ahead and merged these in. Would be better to get the headers
stuff straightened out but that is probably an endless battle.
