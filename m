From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH v5] net: ip, diag -- Add diag interface for raw sockets
Date: Wed, 28 Sep 2016 15:21:57 +0300
Message-ID: <20160928122156.GY1876@uranus.lan>
References: <20160928090357.GT1876@uranus.lan>
 <caef7649-9d25-6429-eeab-96c027d6cbc2@mojatatu.com>
 <20160928101726.GU1876@uranus.lan>
 <8293413c-a81d-f7ff-24f0-8f58ce877116@mojatatu.com>
 <20160928105147.GV1876@uranus.lan>
 <484dedaf-4e81-9a5a-ffb8-2c65b373c3a0@mojatatu.com>
 <20160928112703.GW1876@uranus.lan>
 <696ed966-991c-30f7-9a1c-d91a94c9304c@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:33323 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932179AbcI1MWA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 08:22:00 -0400
Content-Disposition: inline
In-Reply-To: <696ed966-991c-30f7-9a1c-d91a94c9304c@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 28, 2016 at 08:06:51AM -0400, Jamal Hadi Salim wrote:
> 
> I understood well your point;-> Maybe my response was not clear:
> _nobody should be fscking fondling pad fields_ setting them or
> otherwise.
> Maybe let these programs fail. I asked if you knew any such app which
> did anything with a pad field.

Nope, I don't know such programs. criu and iproute2 both zeroify
this strcuture explicitly by whole. But who knows where else this
structure used in userspace world.
