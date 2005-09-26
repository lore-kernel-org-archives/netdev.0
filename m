From: Michael Bellion <mbellion@hipac.org>
Subject: Re: [ANNOUNCE] Release of nf-HiPAC 0.9.0
Date: Mon, 26 Sep 2005 15:16:16 +0200
Message-ID: <200509261516.16565.mbellion__29538.7244820178$1127740791$gmane$org@hipac.org>
References: <200509260445.46740.mbellion@hipac.org> <1127733492.6215.274.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-6"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1127733492.6215.274.camel@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

> Can you post some numbers relative to iptables?

We have some performance tests available at:
http://www.hipac.org/performance_tests/overview.html

We also have a list of the independent performance tests we know of:
http://www.hipac.org/performance_tests/independent.html

> Some tests with the following parameters would be helpful:
> - Variable incoming packet rate (in packets per second)
> - Variable packet sizes
> - Variable number of users/filters
> - Effect of adding/removing/modifying policies while under different
> incoming traffic rates.

Most of this parameters are used in the performance tests above.

The effect of adding/removing/modifying policies while under different
incoming traffic rates has not been tested in the above tests.

nf-HiPAC is based on a completely dynamic approach.
This means that the algorithm used in HiPAC makes sure that the lookup data 
structure is not rebuild from scratch again as soon as you make a update of 
the data structure.
Instead during an update of the policies only the required changes of the 
lookup data structure are made. This guaranties that the packet processing is 
only affected to the least possible amount during updates.

It would certainly be nice to see some benchmark results for this case. 
nf-HiPAC is expected to handle this very well, because it was designed with 
this case in mind.

Regards
    +---------------------------+
    |      Michael Bellion      |
    |   <mbellion@hipac.org>    |
    +---------------------------+
