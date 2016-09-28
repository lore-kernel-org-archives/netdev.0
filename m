From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH v5] net: ip, diag -- Add diag interface for raw sockets
Date: Wed, 28 Sep 2016 15:57:53 +0300
Message-ID: <20160928125753.GB1876@uranus.lan>
References: <20160928112703.GW1876@uranus.lan>
 <20160928.080701.1194277590163223525.davem@davemloft.net>
 <60b2e075-e852-f0c2-c188-631f547791d5@mojatatu.com>
 <20160928.081646.1634500099795129398.davem@davemloft.net>
 <70b51ac5-a7d1-8b52-90c4-7f80ec8ad4d5@mojatatu.com>
 <20160928124520.GZ1876@uranus.lan>
 <5c1cff4e-25bc-5356-a8f8-f5fa44b2a439@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
        dsa@cumulusnetworks.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        avagin@openvz.org, stephen@networkplumber.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:36308 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932124AbcI1M54 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 08:57:56 -0400
Content-Disposition: inline
In-Reply-To: <5c1cff4e-25bc-5356-a8f8-f5fa44b2a439@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 28, 2016 at 08:50:31AM -0400, Jamal Hadi Salim wrote:
> 
> struct tcp_info.

Yeah I see. As I said naming pads will be safe but to do so we
will have to compile on every arch we support and make sure the
implicit pad remains here.

> Sorry - i didnt mean to drag this for long; but the more i think
> about it, the union is a pragmatic approach.

Sure, lets keep it as is.
