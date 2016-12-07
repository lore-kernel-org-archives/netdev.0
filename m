From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 iproute2/net-next 0/3] tc: flower: Support matching
 on ICMP
Date: Wed, 7 Dec 2016 09:21:55 -0800
Message-ID: <20161207092155.4d51ca84@xeon-e3>
References: <1481118843-10428-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:33583 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752479AbcLGRW5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 12:22:57 -0500
Received: by mail-pg0-f46.google.com with SMTP id 3so164089794pgd.0
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 09:22:03 -0800 (PST)
In-Reply-To: <1481118843-10428-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  7 Dec 2016 14:54:00 +0100
Simon Horman <simon.horman@netronome.com> wrote:

> Add support for matching on ICMP type and code to flower. This is modeled
> on existing support for matching on L4 ports.
> 
> The second patch provided a minor cleanup which is in keeping with
> they style used in the last patch.
> 
> This is marked as an RFC to match the same designation given to the
> corresponding kernel patches.
> 
> 
> Changes since v1:
> * Rebase
> * Do not run noths() on u8 entity
> 
> Simon Horman (3):
>   tc: flower: update headers for TCA_FLOWER_KEY_ICMP*
>   tc: flower: introduce enum flower_endpoint
>   tc: flower: support matching on ICMP type and code
> 
>  include/linux/pkt_cls.h |  10 ++++
>  man/man8/tc-flower.8    |  20 ++++++--
>  tc/f_flower.c           | 123 +++++++++++++++++++++++++++++++++++++++++++-----
>  3 files changed, 135 insertions(+), 18 deletions(-)
> 

I am holding of applying these to net-next until David applies kernel
portion.
