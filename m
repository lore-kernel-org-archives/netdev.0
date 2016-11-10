From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next v5 0/9] net: add support for IPv6 Segment Routing
Date: Thu, 10 Nov 2016 18:14:39 +0900
Message-ID: <CAKD1Yr1OGn_JS_REOL9g5gELf9s=VdGfebSrticF2=Vf-m5oKA@mail.gmail.com>
References: <1478613467-27712-1-git-send-email-david.lebrun@uclouvain.be>
 <20161109.204058.1740541278564630528.davem@davemloft.net> <CAKD1Yr0fDFdDv9+S3i_rH6W6btEuvs9s-h33_N67iM4qrtDezQ@mail.gmail.com>
 <58243939.5000200@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:37862 "EHLO
        mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754394AbcKJJPA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 04:15:00 -0500
Received: by mail-it0-f51.google.com with SMTP id u205so27911717itc.0
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:15:00 -0800 (PST)
In-Reply-To: <58243939.5000200@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 10, 2016 at 6:09 PM, David Lebrun <david.lebrun@uclouvain.be> wrote:
> Oops. The easiest fix I can think of is adding an option to
> enable/disable seg6's LWT which would select CONFIG_LWTUNNEL. That would
> still let the core SR processing be enabled by default.

So you'd split SRH functionality in three parts? Core (default on),
lwtunnel (default off) and inline?

It seems to me that once you've done the work to enable the core code
to work when CONFIG_LWTUNNEL is off, you can just enable/disable the
LWT part of SRH depending on whether CONFIG_LWTUNNEL is compiled in or
not. That might save you a config option.
