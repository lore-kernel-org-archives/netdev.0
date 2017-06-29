From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next v3 0/9] introduce flower offload capabilities
Date: Thu, 29 Jun 2017 15:56:29 -0700
Message-ID: <20170629155629.41e8a424@cakuba.netronome.com>
References: <1498766899-30707-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        oss-drivers@netronome.com, Or Gerlitz <gerlitz.or@gmail.com>,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:33345 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751685AbdF2W4h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 18:56:37 -0400
Received: by mail-pg0-f47.google.com with SMTP id f127so54509095pgc.0
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 15:56:37 -0700 (PDT)
In-Reply-To: <1498766899-30707-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 Jun 2017 22:08:10 +0200, Simon Horman wrote:
> Hi,
> 
> this series adds flower offload to the NFP driver. It builds on recent
> work to add representor and a skeleton flower app - now the app does what
> its name says.
> 
> In general the approach taken is to allow some flows within
> the universe of possible flower matches and tc actions to be offloaded.
> It is planned that this support will grow over time but the support
> offered by this patch-set seems to be a reasonable starting point.
> 
> Key Changes since v2:
> * Revised flow structures to simplify setup/teardown and locking of stats
> * Addressed other code-change review of v2
> 
> Other review questions regarding v2 have been answered on netdev.

Looks OK, thanks Simon and Pieter!

Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
