From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 02/12] ftgmac100: Move ftgmac100_hard_start_xmit() around
Date: Sat, 08 Apr 2017 09:19:56 +1000
Message-ID: <1491607196.4166.166.camel@kernel.crashing.org>
References: <20170407033105.29558-1-benh@kernel.crashing.org>
         <20170407033105.29558-3-benh@kernel.crashing.org>
         <20170407.054907.736146169595152256.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:36650 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751221AbdDGXUD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 19:20:03 -0400
In-Reply-To: <20170407.054907.736146169595152256.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-04-07 at 05:49 -0700, David Miller wrote:
> >        /* Tx ring */
> > +     struct sk_buff *tx_skbs[TX_QUEUE_ENTRIES];
> >        unsigned int tx_clean_pointer;
> >        unsigned int tx_pointer;
> >        unsigned int tx_pending;
> 
> Add this only in patch #6 or wherever it is that you start using it,
> not this patch

Yup, just an accident, funny that I didn't notice it (I did review my
own series ;-)

Thanks !

Ben.
