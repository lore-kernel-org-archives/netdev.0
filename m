From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH net-next 0/4] gtp: support multiple APN's per GTP endpoint
Date: Tue, 14 Mar 2017 14:52:59 +0100
Message-ID: <20170314135259.xcu6d24higtla7k5@nataraja>
References: <20170314112548.24027-1-aschultz@tpip.net>
 <20170314114538.GC2992@salvia>
 <2005226672.385248.1489495364893.JavaMail.zimbra@tpip.net>
 <20170314134216.GA4170@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        osmocom-net-gprs <osmocom-net-gprs@lists.osmocom.org>,
        netdev <netdev@vger.kernel.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:42380 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750780AbdCNOPG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 10:15:06 -0400
Content-Disposition: inline
In-Reply-To: <20170314134216.GA4170@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andreas,

On Tue, Mar 14, 2017 at 02:42:16PM +0100, Pablo Neira Ayuso wrote:
> On Tue, Mar 14, 2017 at 01:42:44PM +0100, Andreas Schultz wrote:
> > The only supported and documented API for the GTP module is libgtpnl.
> 
> No, the netlink interface itself if the API.
> 
> Stopping trying to find a reason to break API, that is a no-go.

As much as one might dislike it as a developer in this particular case,
the Linux kernel has the very well communicated rule: All userspace
visible interfaces must not change in an incompatible way.  This
includes of course all the syscalls, the ioctl() parameters but also the
netlink interfaces of the networking stack.

The statement "nobody ever used it" is a statement you can never make in
FOSS software, as you don't know of 99.9999999% of all the users of your
software.  The fact that none of the FOSS projects that any of us was
involved in may not have used a certain feature doesn't mean nobody else
has been using it privately, quietly.  Keep in mind that several Linux
distributions have already been shipping the gtp module as part of their
stable releases meanwhile.

Also, no matter what Pablo or I may think about, there are general rules
about how Linux kernel development is done (from coding style to merge
windows, and also userspace compatibility), and we all have to obey
them.  There's little point in discussing about them, we all just have
to live with them.

Regards,
	Harald
-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
