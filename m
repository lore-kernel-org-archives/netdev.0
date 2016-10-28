From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Why do we need tasklet in IFB?
Date: Fri, 28 Oct 2016 14:38:08 -0700
Message-ID: <20161028143808.3134f296@xeon-e3>
References: <CAAmHdhz_g5_+Uqp47cPm3NQd=8=9tCecddQLVCfHbChx=Tjhcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Michael Ma <make0818@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35330 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753749AbcJ1Vh4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 17:37:56 -0400
Received: by mail-pf0-f180.google.com with SMTP id s8so43269233pfj.2
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 14:37:55 -0700 (PDT)
In-Reply-To: <CAAmHdhz_g5_+Uqp47cPm3NQd=8=9tCecddQLVCfHbChx=Tjhcw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Oct 2016 14:36:27 -0700
Michael Ma <make0818@gmail.com> wrote:

> Hi -
> 
> Currently IFB uses tasklet to process tx/rx on the interface that
> forwarded the packet to IFB. My understanding on why we're doing this
> is that since dev_queue_xmit() can be invoked in interrupt, we want to
> defer the processing of original tx/rx in case ifb_xmit() is called
> from interrupt.

dev_queue_xmit is only called from interrupt if doing netconsole.
