From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] selftests: add a generic testsuite for ethernet device
Date: Tue, 4 Apr 2017 14:22:58 +0200
Message-ID: <20170404122258.GC31409@lunn.ch>
References: <20170331125752.20074-1-clabbe.montjoie@gmail.com>
 <20170331125752.20074-2-clabbe.montjoie@gmail.com>
 <20170331141241.GH22609@lunn.ch>
 <20170403131526.GC30824@Red>
 <20170403132741.GC17550@lunn.ch>
 <20170404075604.GA13800@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, shuah@kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45019 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752893AbdDDMXE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Apr 2017 08:23:04 -0400
Content-Disposition: inline
In-Reply-To: <20170404075604.GA13800@Red>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 04, 2017 at 09:56:04AM +0200, Corentin Labbe wrote:
> On Mon, Apr 03, 2017 at 03:27:41PM +0200, Andrew Lunn wrote:
> > > By ifnum, you mean by the order that "ip link" gives ?
> > 
> > I've not checked if it remains in order as interfaces are hot
> > plugged/unplugged. But i guess you are running tests direct after
> > boot, and unplugs/replugs are unlikely?
> > 
> 
> Yes the ideal run is just after boot, but the test need to succeed in all case.
> 
> For handling vlan, I think the best way is to detect the master interface by looking the "@master".

Hi Corentin

In my case, these are DSA interfaces. Documentation/networking/dsa/dsa.txt

> So when testing a vlan interface, the test would just up also the masteri interface.

That will work for DSA. 

I know kernelci.org has at least two boards with Ethernet switches
that will have such interfaces. So it is great to test them.

Thanks
     Andrew
