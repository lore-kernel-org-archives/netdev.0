From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] net: Introduce a socket option to enable picking tx
 queue based on rx queue.
Date: Mon, 11 Sep 2017 20:53:57 -0700
Message-ID: <1505188437.15310.137.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1504222032-6337-1-git-send-email-sridhar.samudrala@intel.com>
         <CALx6S35sM1CDrFuNE+L59Op_wKTRpATLAdRJafihr0mB9+vQ8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sridhar.samudrala@intel.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:33752 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751041AbdILDx7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 23:53:59 -0400
Received: by mail-pg0-f53.google.com with SMTP id u18so2517219pgo.0
        for <netdev@vger.kernel.org>; Mon, 11 Sep 2017 20:53:59 -0700 (PDT)
In-Reply-To: <CALx6S35sM1CDrFuNE+L59Op_wKTRpATLAdRJafihr0mB9+vQ8g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-09-11 at 20:12 -0700, Tom Herbert wrote:

> Two ints in sock_common for this purpose is quite expensive and the
> use case for this is limited-- even if a RX->TX queue mapping were
> introduced to eliminate the queue pair assumption this still won't
> help if the receive and transmit interfaces are different for the
> connection. I think we really need to see some very compelling results
> to be able to justify this.
> 

Yes, this is unreasonable cost.

XPS should really cover the case already.
 
