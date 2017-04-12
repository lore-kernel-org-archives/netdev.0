From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Network driver "test suite"
Date: Tue, 11 Apr 2017 17:36:53 -0700
Message-ID: <3c62188f-1378-a912-3045-97644fa386d5@gmail.com>
References: <1491956177.7236.34.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:34746 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750732AbdDLAg5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 20:36:57 -0400
Received: by mail-pg0-f46.google.com with SMTP id 21so6203608pgg.1
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 17:36:57 -0700 (PDT)
In-Reply-To: <1491956177.7236.34.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 04/11/2017 05:16 PM, Benjamin Herrenschmidt wrote:
> Hi folks !
> 
> Does anybody knows of an existing kind of automated "test suite" for a
> network/ethernet driver ?
> 
> IE. Something we could run both on the "tested" driver and a cross-over 
> "known good" peer (possibly the latter set to promisc & no offload for
> proper analysis), that would out the driver through a whole bunch of
> tests, such as verifying the checksum offload on a various combinations
> of headers lenghts and encapsulation, vlan stuff, multicast filters,
> etc... ?

You could start with using LNST:

https://github.com/jpirko/lnst

and there is also Ostinato which is a great way to get access to
something IXIA-like, but all configurable in software through python
bindings. Andrew's dsa-tests make use of it, but they would not be
directly portable here [1].

[1]: https://github.com/lunn/dsa-tests
-- 
Florian
