From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2/net-next 0/7] tc: flower: Masked ICMP match and
 ND match
Date: Mon, 6 Feb 2017 14:28:47 -0800
Message-ID: <20170206142847.3462ae48@xeon-e3>
References: <1486031920-10784-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:32922 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751450AbdBFW2t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 17:28:49 -0500
Received: by mail-pg0-f46.google.com with SMTP id 204so32050506pge.0
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 14:28:49 -0800 (PST)
In-Reply-To: <1486031920-10784-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  2 Feb 2017 11:38:33 +0100
Simon Horman <simon.horman@netronome.com> wrote:

> Hi,
> 
> this series have several related parts.
> 
> * tc: flower: Update documentation to indicate ARP takes IPv4 prefixes
> 
>   Enhance documentation for consistency with later documentation changes.
> 
> * tc: flower: use correct type when calling flower_icmp_attr_type
> 
>   Type correction to ICMP code; should not have runtime effect
> 
> * tc: flower: provide generic masked u8 parser helper
>   tc: flower: provide generic masked u8 print helper
> 
>   Generic parsing and printing of masked u8 options
> 
> * tc: flower: support masked ICMP code and type match
> 
>   Support masking ICMP code and type matches.
>   Unmasked matching is already supported by iproute2
>   Masked matching is already supported by the kernel.
> 
>   This is used by the ND patches
> 
> * tc: flower: Add TCA_FLOWER_KEY_ND_*
>   tc: flower: Support matching on ND
> 
> The last two patches are marked as RFC as they support functionality
> submitted to but not yet not yet present in the kernel.
> 
> 
> Simon Horman (7):
>   tc: flower: Update documentation to indicate ARP takes IPv4 prefixes
>   tc: flower: use correct type when calling flower_icmp_attr_type
>   tc: flower: provide generic masked u8 parser helper
>   tc: flower: provide generic masked u8 print helper
>   tc: flower: support masked ICMP code and type match
>   tc: flower: Add TCA_FLOWER_KEY_ND_*
>   tc: flower: Support matching on ND
> 
>  include/linux/pkt_cls.h |   7 ++
>  man/man8/tc-flower.8    |  58 +++++++++--
>  tc/f_flower.c           | 260 +++++++++++++++++++++++++++++++++++++-----------
>  3 files changed, 258 insertions(+), 67 deletions(-)
> 

Since this patchset depended on changes to pkt_cls.h which are not accepted upstream
into net-next, I marked it as awaiting upstream.  When the corresponding kernel changes
are accepted into net-next please resubmit it.
