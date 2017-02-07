From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH 1/2] testsuite: skip link show test on big endian
 systems
Date: Wed, 8 Feb 2017 00:49:40 +0100
Message-ID: <20170207234940.GN22796@orbyte.nwl.cc>
References: <20170207230422.31936-1-phil@nwl.cc>
 <20170207230422.31936-2-phil@nwl.cc>
 <20170207151249.19de5192@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:42225 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932077AbdBGX7k (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Feb 2017 18:59:40 -0500
Content-Disposition: inline
In-Reply-To: <20170207151249.19de5192@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 07, 2017 at 03:12:49PM -0800, Stephen Hemminger wrote:
> On Wed,  8 Feb 2017 00:04:21 +0100
> Phil Sutter <phil@nwl.cc> wrote:
> 
> > Netlink protocol is in host byte order, so the provided binary netlink
> > message buffer being in little endian format will cause the test to fail
> > on big endian systems.
> > 
> > Signed-off-by: Phil Sutter <phil@nwl.cc>
> 
> Maybe better to figure out how to generate the files in host order?

Yes, I had thought about that as well. Not sure whether it's worth the
effort though to write a program which constructs the messages and dumps
them into a file for 'ip monitor' to read. I think there's a certain
chance this will eventually test the message builder instead of iproute.
:)

Cheers, Phil
