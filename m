From: Thiago Macieira <thiago.macieira@intel.com>
Subject: Re: [PATCH net] datagram: When peeking datagrams with offset < 0 don't skip empty skbs
Date: Mon, 14 Aug 2017 11:33:48 -0700
Message-ID: <1604496.falisOBPe2@tjmaciei-mobl1>
References: <20170814055259.31078-1-matthew@mjdsystems.ca> <13347366.nbnduK6AMs@tjmaciei-mobl1> <CAF=yD-JwAidB+Hc+sH9woBMR=3JUnbneB3fCRiJ3wmt3gzTcMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Matthew Dawson <matthew@mjdsystems.ca>,
        Paolo Abeni <pabeni@redhat.com>,
        Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:38954 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750936AbdHNSdw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Aug 2017 14:33:52 -0400
In-Reply-To: <CAF=yD-JwAidB+Hc+sH9woBMR=3JUnbneB3fCRiJ3wmt3gzTcMg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, 14 August 2017 11:25:23 PDT Willem de Bruijn wrote:
> > Do applications using SOCK_DGRAM rely on the behaviour of skipping over
> > datagrams that are too short?
> 
> It is established behavior. It cannot be ruled out that an application
> somewhere depends on it.

Understood.

By the way, what were the usecases for the peek offset feature?

Also, do they apply to non-peeking recv?

-- 
Thiago Macieira - thiago.macieira (AT) intel.com
  Software Architect - Intel Open Source Technology Center
