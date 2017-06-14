From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute/master 2/3] iptunnel: add support for mpls/ip to
 sit tunnels
Date: Wed, 14 Jun 2017 10:02:11 -0700
Message-ID: <20170614100211.1346dc4e@xeon-e3>
References: <1497058292-10099-1-git-send-email-kjlx@templeofstupid.com>
        <1497058292-10099-3-git-send-email-kjlx@templeofstupid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, simon.horman@netronome.com,
        dsahern@gmail.com
To: Krister Johansen <kjlx@templeofstupid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35571 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751816AbdFNRCS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 13:02:18 -0400
Received: by mail-pf0-f171.google.com with SMTP id l89so3144517pfi.2
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 10:02:18 -0700 (PDT)
In-Reply-To: <1497058292-10099-3-git-send-email-kjlx@templeofstupid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  9 Jun 2017 18:31:31 -0700
Krister Johansen <kjlx@templeofstupid.com> wrote:

> diff --git a/include/utils.h b/include/utils.h
> index bfbc9e6..60ffde4 100644
> --- a/include/utils.h
> +++ b/include/utils.h
> @@ -87,6 +87,9 @@ struct ipx_addr {
>  #ifndef AF_MPLS
>  # define AF_MPLS 28
>  #endif
> +#ifndef IPPROTO_MPLS
> +#define IPPROTO_MPLS	137
> +#endif
>  

I am a little concerned that this definition may end up being different
between kernel and iproute2.  It looks like utils.h already has lots of duplicate
definitions of things that are in standard include directory.

Most of these like IPSEC and DECNET are old, but MPLS might get changed
in the process of going into glibc.

Is there anyway to get this from the kernel headers which are cloned
into include/linux/ already?
