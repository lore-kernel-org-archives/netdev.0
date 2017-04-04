From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute2 net-next v2 0/3] ip netconf improvements
Date: Tue, 4 Apr 2017 14:39:12 -0700
Message-ID: <20170404143912.7ecae6ba@xeon-e3>
References: <1490323882-11609-1-git-send-email-dsa@cumulusnetworks.com>
        <431908e0-27b0-730d-0c01-671702f30d71@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:34035 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753129AbdDDVlL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 17:41:11 -0400
Received: by mail-pg0-f49.google.com with SMTP id 21so164277808pgg.1
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 14:41:10 -0700 (PDT)
In-Reply-To: <431908e0-27b0-730d-0c01-671702f30d71@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 4 Apr 2017 17:07:31 -0400
David Ahern <dsa@cumulusnetworks.com> wrote:

> On 3/23/17 10:51 PM, David Ahern wrote:
> > Currently, ip netconf only shows data for ipv4 and ipv6 for dumps
> > and just ipv4 for device requests. Improve the user experience by
> > using the new kernel patch to dump all address families that have
> > registered. For example, if mpls_router module is loaded then mpls
> > values are displayed along with ipv4 and ipv6.
> > 
> > If the new feature is not supported (new iproute2 on older kernel)
> > the kernel returns the nlmsg error EOPNOTSUPP which can be trapped
> > and fallback to existing behavior.
> > 
> > v2
> > - fixed index conversion in patch 3 per nicholas' comment
> > 
> > David Ahern (3):
> >   netlink: Add flag to suppress print of nlmsg error
> >   ip netconf: Show all address families by default in dumps
> >   ip netconf: show all families on dev request
> > 
> >  include/libnetlink.h |  1 +
> >  ip/ipnetconf.c       | 36 +++++++++++++++++++++++++-----------
> >  lib/libnetlink.c     |  3 ++-
> >  3 files changed, 28 insertions(+), 12 deletions(-)
> >   
> 
> Hi Stephen: any comments? are you ok with this change?

I was holding off until all the upstream commits went through. Other than
that fine.
