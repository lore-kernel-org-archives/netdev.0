From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2/net-next v3 0/3] tc: flower: SCTP and other
 port fixes
Date: Mon, 5 Dec 2016 10:14:32 -0800
Message-ID: <20161205101432.503e7830@xeon-e3>
References: <1480755160-27768-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33199 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752009AbcLESOf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 13:14:35 -0500
Received: by mail-pf0-f179.google.com with SMTP id d2so64854424pfd.0
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 10:14:35 -0800 (PST)
In-Reply-To: <1480755160-27768-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  3 Dec 2016 09:52:37 +0100
Simon Horman <simon.horman@netronome.com> wrote:

> Hi Stephen,
> 
> this short series:
> 
> * Makes some improvements to the documentation of flower;
>   A follow-up to recent work by Paul Blakey and myself.
> * Corrects some errors introduced when SCTP port matching support was
>   recently added.
> 
> Changes v2->v3:
> * Rebase
> * Dropped merged patch
> 
> Changes v1->v2:
> * Rebase
> 
> Simon Horman (3):
>   tc: flower: document SCTP ip_proto
>   tc: flower: correct name of ip_proto parameter to flower_parse_port()
>   tc: flower: make use of flower_port_attr_type() safe and silent
> 
>  man/man8/tc-flower.8 | 14 +++++++-------
>  tc/f_flower.c        | 32 +++++++++++++++++---------------
>  2 files changed, 24 insertions(+), 22 deletions(-)
> 

Applied to net-next
