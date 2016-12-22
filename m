From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2/net-next 0/2] tc: flower: enhance mask support
Date: Wed, 21 Dec 2016 16:09:08 -0800
Message-ID: <20161221160908.2216a78c@xeon-e3>
References: <1481896477-13497-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:33490 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757629AbcLVAJL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 19:09:11 -0500
Received: by mail-pg0-f53.google.com with SMTP id g1so51345470pgn.0
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2016 16:09:10 -0800 (PST)
In-Reply-To: <1481896477-13497-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 Dec 2016 14:54:35 +0100
Simon Horman <simon.horman@netronome.com> wrote:

> Hi,
> 
> this short series enhances mask support for tc flower by:
> * Documenting existing mask support for *_ip parameters
> * Allowing *_mac options to accept a mask.
>   This makes use of existing kernel features.
> 
> Based on net-next +
> "[PATCH iproute2 0/2] Add dest UDP port to IP tunnel parameters"
> 
> Simon Horman (2):
>   tc: flower: document that *_ip parameters take a PREFIX as an
>     argument.
>   tc: flower: Allow *_mac options to accept a mask
> 
>  man/man8/tc-flower.8 | 41 +++++++++++++++++++++++------------------
>  tc/f_flower.c        | 51 ++++++++++++++++++++++++++++++++++++++++-----------
>  2 files changed, 63 insertions(+), 29 deletions(-)
> 

Thanks, applied to net-next.
Initially applied to wrong tree then reapplied to right tree.
