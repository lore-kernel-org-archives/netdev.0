From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net repost] nfp: do not update MTU from BH in flower app
Date: Tue, 15 Aug 2017 08:13:48 +0200
Message-ID: <20170815061347.GA14861@vergenet.net>
References: <1502439500-16047-1-git-send-email-simon.horman@netronome.com>
 <20170811.145107.1539668262080149471.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jakub.kicinski@netronome.com, netdev@vger.kernel.org,
        oss-drivers@netronome.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:34571 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752134AbdHOGNv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 02:13:51 -0400
Received: by mail-wm0-f47.google.com with SMTP id t138so21539860wmt.1
        for <netdev@vger.kernel.org>; Mon, 14 Aug 2017 23:13:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170811.145107.1539668262080149471.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 11, 2017 at 02:51:07PM -0700, David Miller wrote:
> From: Simon Horman <simon.horman@netronome.com>
> Date: Fri, 11 Aug 2017 10:18:20 +0200
> 
> > The Flower app may receive a request to update the MTU of a representor
> > netdev upon receipt of a control message from the firmware. This requires
> > the RTNL lock which needs to be taken outside of the packet processing
> > path.
> > 
> > As a handling of this correctly seems a little to invasive for a fix simply
> > skip setting the MTU for now.
> > 
> > Relevant backtrace:
>  ...
> > Fixes: 948faa46c05b ("nfp: add support for control messages for flower app")
> > Signed-off-by: Simon Horman <simon.horman@netronome.com>
> > Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> 
> Applied.

Thanks.

Could you pull net into net-next? I'd like to send up a follow-up
for net-next to allow processing of the MTU.
