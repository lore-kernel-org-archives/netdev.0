From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH] selftests: add a generic testsuite for ethernet device
Date: Tue, 4 Apr 2017 09:56:04 +0200
Message-ID: <20170404075604.GA13800@Red>
References: <20170331125752.20074-1-clabbe.montjoie@gmail.com>
 <20170331125752.20074-2-clabbe.montjoie@gmail.com>
 <20170331141241.GH22609@lunn.ch>
 <20170403131526.GC30824@Red>
 <20170403132741.GC17550@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, shuah@kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170403132741.GC17550@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 03, 2017 at 03:27:41PM +0200, Andrew Lunn wrote:
> > By ifnum, you mean by the order that "ip link" gives ?
> 
> I've not checked if it remains in order as interfaces are hot
> plugged/unplugged. But i guess you are running tests direct after
> boot, and unplugs/replugs are unlikely?
> 

Yes the ideal run is just after boot, but the test need to succeed in all case.

For handling vlan, I think the best way is to detect the master interface by looking the "@master".
So when testing a vlan interface, the test would just up also the masteri interface.

So I will drop using "ls /sys/clas/net/" and directly use output of ip

Regards
