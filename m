From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: ethtool -d no longer works for e1000
Date: Fri, 11 Mar 2005 09:54:56 +0100
Message-ID: <20050311085456.GA3253@xi.wantstofly.org>
References: <422F6C37.8090202@candelatech.com> <5fc59ff3050309140910f3e492@mail.gmail.com> <422F822D.9010707@candelatech.com> <200503091713.55454.jdmason@us.ibm.com> <422F8737.7050002@candelatech.com> <422F89CB.2070705@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jon Mason <jdmason@us.ibm.com>,
        Ganesh Venkatesan <ganesh.venkatesan@gmail.com>,
        "netdev@oss.sgi.com" <netdev@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <422F89CB.2070705@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 09, 2005 at 03:42:03PM -0800, Ben Greear wrote:

> >>I don't see this problem at all on my 2.6.11-rc4-mm1 kernel (Athlon64 
> >>proc).
> >
> >I think I see the problem.  ethtool -d eth0 works for me,
> >but ethtool -d eth1 does not, even with both are e1000
> >NICs.  It appears it cannot handle reading the second NIC for
> >some reason?
> 
> Errr, my bad.  The problem is more that the dual-port pro/1000 NICs
> don't seem to work, but the built-in e1000s do.
> 
> The chipset that does not work correctly is: 82546GB
> 
> The NICs with chipset: 82541EI seem to work just fine.

"Me too."

Works fine: 82540EM (SE7505VB2 on-board e1000)
Doesn't work: 82546GB (dual port e1000 server NIC)

[root@phi ~]# uname -a
Linux phi.wantstofly.org 2.6.10-1.766_FC3smp #1 SMP Wed Feb 9 23:21:37 EST 2005 i686 i686 i386 GNU/Linux

[root@phi ~]# ethtool -d eth1
Cannot dump registers: Success
[root@phi ~]# ethtool -d eth2
Cannot dump registers: Success
[root@phi ~]# ethtool -d eth3 | head -3
MAC Registers
-------------
0x00000: CTRL (Device control register)  0x003C0249

Nothing appears in syslog.


--L
