From: Harald Welte <laforge@gnumonks.org>
Subject: Re: RFC: unit tests for kernel GTP module
Date: Fri, 17 Feb 2017 19:03:16 +0100
Message-ID: <20170217180316.ujzsbnb2s2ee44iw@nataraja>
References: <20170216220801.o3fajacj4sx3iere@nataraja>
 <1507789126.143172.1487343779235.JavaMail.zimbra@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@gnumonks.org>,
        netdev <netdev@vger.kernel.org>,
        osmocom-net-gprs <osmocom-net-gprs@lists.osmocom.org>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:56208 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934053AbdBQSQR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 13:16:17 -0500
Content-Disposition: inline
In-Reply-To: <1507789126.143172.1487343779235.JavaMail.zimbra@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andreas,

On Fri, Feb 17, 2017 at 04:02:59PM +0100, Andreas Schultz wrote:
> The test suite is proprietary, so we can only share the results but
> not the test setup itself.

it would be great to have some CI setup where both current stable as
well as a development branch of the code is tested, and reports
published regularly.  Not sure how realistic that is.

> We more or less removed static GTP tunnels. The tools in libgtpnl
> only work when an application is keeping the GTP socket alive.

Well, then those tools need to be adapted accordingly.  That's what I
also indicated in other mails:  Changes in the kernel GTP code should
always be followed-up with correspondign changes in libgtpnl and
associated tools.  I mean, the tool could just open the socket and then
continue to run until terminated explicitly...

I think there's a lot of value in some very low-level tools for testing
and experimentation, without the complexity of configuring + running an
Erlang GGSN/P-GW with all its dependencies.

-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
