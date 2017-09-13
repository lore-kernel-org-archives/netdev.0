From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH] ipaddress: Fix segfault in 'addr showdump'
Date: Wed, 13 Sep 2017 11:13:00 +0200
Message-ID: <20170913091300.GS30364@orbyte.nwl.cc>
References: <20170912145812.15380-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hangbin Liu <liuhangbin@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:50162 "EHLO orbyte.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751317AbdIMJNC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 13 Sep 2017 05:13:02 -0400
Content-Disposition: inline
In-Reply-To: <20170912145812.15380-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 12, 2017 at 04:58:12PM +0200, Phil Sutter wrote:
> Obviously, 'addr showdump' feature wasn't adjusted to json output
> support. As a consequence, calls to print_string() in print_addrinfo()
> tried to dereference a NULL FILE pointer.

Please ignore this patch - it generates incorrect json output. I'll send
a v2 which fixes that.

Thanks, Phil
