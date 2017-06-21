From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v2 11/12] nfp: add flower app
Date: Wed, 21 Jun 2017 11:59:35 +0200
Message-ID: <20170621095933.GC6691@vergenet.net>
References: <1497994580-6271-1-git-send-email-simon.horman@netronome.com>
 <1497994580-6271-12-git-send-email-simon.horman@netronome.com>
 <CAJ3xEMjqABvksewqgP=KTm3vvE6z9BpryuQJObB7eWD3WntN6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f176.google.com ([209.85.128.176]:35139 "EHLO
        mail-wr0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751223AbdFUJ7r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 05:59:47 -0400
Received: by mail-wr0-f176.google.com with SMTP id y25so88393888wrd.2
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 02:59:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMjqABvksewqgP=KTm3vvE6z9BpryuQJObB7eWD3WntN6g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 21, 2017 at 12:04:17PM +0300, Or Gerlitz wrote:
> On Wed, Jun 21, 2017 at 12:36 AM, Simon Horman
> <simon.horman@netronome.com> wrote:
> > Add app for flower offload. At this point the PF netdev and phys port
> > representor netdevs are initialised. Follow-up work will add support for
> > VF and PF representors and beyond that offloading the flower classifier.
> 
> FWIW, repeating here my comment made on the V1 cover letter, in case you
> want to discuss it here V2 -- the VF reps can apply for more use cases
> beyond flower offload -- e.g FDB or FIB offloads and also the other way
> around, flower offloads can apply to more use cases beyond SRIOV, as any
> easy example, you can offload native NIC RX TC rule (drop, header
> re-write, etc).
> 
> Not sure why you want to make this tie

Lets discuss in the v1 thread as I have now replied there.
