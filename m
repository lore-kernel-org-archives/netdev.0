From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: Network driver "test suite"
Date: Wed, 12 Apr 2017 09:18:57 +0200
Message-ID: <20170412071857.GB11170@Red>
References: <1491956177.7236.34.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:36065 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753179AbdDLHTB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 03:19:01 -0400
Received: by mail-wm0-f46.google.com with SMTP id o81so79903544wmb.1
        for <netdev@vger.kernel.org>; Wed, 12 Apr 2017 00:19:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1491956177.7236.34.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 12, 2017 at 10:16:17AM +1000, Benjamin Herrenschmidt wrote:
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
> 
> I've hacking on a driver recently and ended up "manually" testing a
> bunch of these things using a palette of tools (iperf, nuttcp, some
> multicast hack I have around, etc... along with tcpdump) but it feels
> like this is the kind of things that could be greatly automated.
> 
> Cheers,
> Ben.
> 

I have started to add some tests to kselftests (tools/testing/selftests/net/netdevice.sh)
The major intent is that thoses tests could be run without any user directive. (and so could be usefull in kernelci)
I just need to share the next serie of patch.

Regards
