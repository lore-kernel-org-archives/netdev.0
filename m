From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2/net-next 0/2] net/sched: cls_flower: Support
 matching ARP
Date: Thu, 12 Jan 2017 17:47:04 -0800
Message-ID: <20170112174704.79a6f764@xeon-e3>
References: <1484208719-1581-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34383 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750819AbdAMBrL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 20:47:11 -0500
Received: by mail-pf0-f178.google.com with SMTP id 127so21861124pfg.1
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 17:47:11 -0800 (PST)
In-Reply-To: <1484208719-1581-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Jan 2017 09:11:57 +0100
Simon Horman <simon.horman@netronome.com> wrote:

> Add support for support matching on ARP operation, and hardware and
> protocol addresses for Ethernet hardware and IPv4 protocol addresses.
> 
> Changes since RFC:
> * Drop RFC designation; kernel patches are present in net-next
> 
> Simon Horman (2):
>   tc: flower: update headers for TCA_FLOWER_KEY_ARP*
>   tc: flower: Support matching ARP
> 
>  include/linux/pkt_cls.h |  11 +++
>  man/man8/tc-flower.8    |  41 +++++++++-
>  tc/f_flower.c           | 208 ++++++++++++++++++++++++++++++++++++++++++++----
>  3 files changed, 243 insertions(+), 17 deletions(-)
> 

Applied to net-next
