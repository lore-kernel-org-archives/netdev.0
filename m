From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next 0/7] nfp: flower vxlan tunnel offload
Date: Wed, 27 Sep 2017 09:27:59 +0200
Message-ID: <20170927072758.GB19034@vergenet.net>
References: <1506335021-32024-1-git-send-email-simon.horman@netronome.com>
 <20170926.212903.454497939014837374.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jakub.kicinski@netronome.com, netdev@vger.kernel.org,
        oss-drivers@netronome.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f180.google.com ([209.85.128.180]:49478 "EHLO
        mail-wr0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751471AbdI0H2C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 03:28:02 -0400
Received: by mail-wr0-f180.google.com with SMTP id h16so700740wrf.6
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 00:28:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170926.212903.454497939014837374.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 26, 2017 at 09:29:03PM -0700, David Miller wrote:
> From: Simon Horman <simon.horman@netronome.com>
> Date: Mon, 25 Sep 2017 12:23:34 +0200
> 
> > From: Simon Horman <simon.horman@netronome.com>
> > 
> > John says:
> > 
> > This patch set allows offloading of TC flower match and set tunnel fields
> > to the NFP. The initial focus is on VXLAN traffic. Due to the current
> > state of the NFP firmware, only VXLAN traffic on well known port 4789 is
> > handled. The match and action fields must explicity set this value to be
> > supported. Tunnel end point information is also offloaded to the NFP for
> > both encapsulation and decapsulation. The NFP expects 3 separate data sets
> > to be supplied.
>  ...
> 
> Series applied, thanks.
> 
> I see there is some discussion about ipv6 flow dissector key handling
> and ND keepalives, but those should be addressable in follow-on changes.

Thanks Dave,

I'll make sure that discussion is brought to a satisfactory conclusion.
