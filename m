From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v2 8/9] nfp: add a stats handler for flower
 offloads
Date: Thu, 29 Jun 2017 16:53:54 +0200
Message-ID: <20170629145352.GA6215@vergenet.net>
References: <1498681802-2897-1-git-send-email-simon.horman@netronome.com>
 <1498681802-2897-9-git-send-email-simon.horman@netronome.com>
 <CAJ3xEMgUQKyf2d0KB1ZKeKVYcNN65X8U0X55riJv2ebs-w2bGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:33292 "EHLO
        mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752852AbdF2OyC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 10:54:02 -0400
Received: by mail-qk0-f169.google.com with SMTP id r62so78277312qkf.0
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 07:54:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMgUQKyf2d0KB1ZKeKVYcNN65X8U0X55riJv2ebs-w2bGg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 29, 2017 at 05:39:34PM +0300, Or Gerlitz wrote:
> On Wed, Jun 28, 2017 at 11:30 PM, Simon Horman
> <simon.horman@netronome.com> wrote:
> > From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
> >
> > Previously there was no way of updating flow rule stats after they
> > have been offloaded to hardware. This is solved by keeping track of
> > stats received from hardware and providing this to the TC handler
> > on request.
> 
> 
> You are using the term/variable "unmasked_data" across the code, to
> make it clear
> the keys provided to the driver are masked by the tcflower kernel code
> [1] - what do
> you mean by unmasked data?
> 
> Or.
> 
> [1] f93bd17 net/sched: cls_flower: Use masked key when calling HW offloads

>From a firmware point of view there is an unmasked key and a mask.
These are referred to as unmasked_data and mask_data although in
TC supplies a masked key which the firmware can also handle.
