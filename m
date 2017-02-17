From: Ido Schimmel <idosch@idosch.org>
Subject: Re: RFC: unit tests for kernel GTP module
Date: Fri, 17 Feb 2017 12:22:22 +0200
Message-ID: <20170217102222.GA5566@splinter.mtl.com>
References: <20170216220801.o3fajacj4sx3iere@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: osmocom-net-gprs@lists.osmocom.org, netdev@vger.kernel.org,
        Pablo Neira Ayuso <pablo@gnumonks.org>,
        Andreas Schultz <aschultz@tpip.net>, jiri@mellanox.com,
        olichtne@redhat.com
To: Harald Welte <laforge@gnumonks.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:45625 "EHLO
        out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932374AbdBQKW0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 05:22:26 -0500
Content-Disposition: inline
In-Reply-To: <20170216220801.o3fajacj4sx3iere@nataraja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, Feb 16, 2017 at 11:08:01PM +0100, Harald Welte wrote:
> Also, if netdev folks have some ideas/pointers about possible
> frameworks/tools for this kind of testing [it must exist for at least
> some other kernel networking code?]: Please let me know.  I'd be
> interested to have a look if there's something that can be used as a
> basis (starting network namespaces, sending/transmitting packets, test
> case startup/teardown, ...)

I'm not sure it meets all your needs, but we use LNST [1] to test our
code. You can see the tests (recipes) here [2]. You can create network
namespaces, send / receive packets, run arbitrary shell commands and
use existing test modules (e.g., ping, netperf) which return pass /
fail.

Adding Jiri and Ondrej, who is currently in the process of refactoring
the code and also familiar with more LNST use cases, such as those
employed by Redhat.

1. https://github.com/jpirko/lnst
2. https://github.com/jpirko/lnst/tree/master/recipes/
