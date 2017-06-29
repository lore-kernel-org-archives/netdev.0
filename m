From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v2 3/9] nfp: provide infrastructure for
 offloading flower based TC filters
Date: Thu, 29 Jun 2017 07:41:42 +0200
Message-ID: <20170629054140.GA2643@vergenet.net>
References: <1498681802-2897-1-git-send-email-simon.horman@netronome.com>
 <1498681802-2897-4-git-send-email-simon.horman@netronome.com>
 <20170628183507.3b3720ce@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f169.google.com ([209.85.216.169]:36595 "EHLO
        mail-qt0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751591AbdF2Fls (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 01:41:48 -0400
Received: by mail-qt0-f169.google.com with SMTP id i2so66357331qta.3
        for <netdev@vger.kernel.org>; Wed, 28 Jun 2017 22:41:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170628183507.3b3720ce@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 28, 2017 at 06:35:07PM -0700, Jakub Kicinski wrote:
> On Wed, 28 Jun 2017 22:29:56 +0200, Simon Horman wrote:
> > From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
> > 
> > Adds a flower based TC offload handler for representor devices, this
> > is in addition to the bpf based offload handler. The changes in this
> > patch will be used in a follow-up patch to add tc flower offload to
> > the NFP.
> > 
> > The flower app enables tc offloads on representors by default.
> > 
> > Signed-off-by: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
> > Signed-off-by: Simon Horman <simon.horman@netronome.com>
> 
> Thanks, two nits, since it seems like there will have to be another
> respin.

Thanks, I will fix those in v3.
