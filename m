From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/1 V2] tc: custom qdisc pkt size translation table
Date: Tue, 4 Jul 2017 11:15:37 -0700
Message-ID: <20170704111537.1886adda@xeon-e3>
References: <20170704155058.19608-1-Robert.McCabe@rockwellcollins.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, McCabe@rockwellcollins.com
To: "McCabe, Robert J" <Robert.McCabe@rockwellcollins.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:33322 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752127AbdGDSPk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 14:15:40 -0400
Received: by mail-pg0-f49.google.com with SMTP id k14so37384596pgr.0
        for <netdev@vger.kernel.org>; Tue, 04 Jul 2017 11:15:39 -0700 (PDT)
In-Reply-To: <20170704155058.19608-1-Robert.McCabe@rockwellcollins.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  4 Jul 2017 10:50:58 -0500
"McCabe, Robert J" <Robert.McCabe@rockwellcollins.com> wrote:

> Added the "custom" linklayer qdisc stab option.
> Allows the user to specify the pkt size translation
> parameters from stdin.
> Example:
>    tc qdisc add ... stab tsize 8 linklayer custom htb
>       Custom size table:
>       InputSizeStart -> IntputSizeEnd: OutputSize
>       0              -> 511          : 600
>       512            -> 1023         : 1200
>       1024           -> 1535         : 1800
>       1536           -> 2047         : 2400
>       2048           -> 2559         : 3000
> 
> Signed-off-by: McCabe, Robert J <Robert.McCabe@rockwellcollins.com>

LINKLAYER_CUSTOM was not accepted into the upstream net-next kernel.
Please resubmit after the kernel portion is accepted into net-next.
