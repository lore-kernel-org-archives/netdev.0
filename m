From: Ben Greear <greearb@candelatech.com>
Subject: Re: ethtool -d no longer works for e1000
Date: Wed, 09 Mar 2005 15:42:03 -0800
Message-ID: <422F89CB.2070705@candelatech.com>
References: <422F6C37.8090202@candelatech.com> <5fc59ff3050309140910f3e492@mail.gmail.com> <422F822D.9010707@candelatech.com> <200503091713.55454.jdmason@us.ibm.com> <422F8737.7050002@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>,
        "netdev@oss.sgi.com" <netdev@oss.sgi.com>
To: Jon Mason <jdmason@us.ibm.com>
In-Reply-To: <422F8737.7050002@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> Jon Mason wrote:
> 
>> I don't see this problem at all on my 2.6.11-rc4-mm1 kernel (Athlon64 
>> proc).
> 
> 
> I think I see the problem.  ethtool -d eth0 works for me,
> but ethtool -d eth1 does not, even with both are e1000
> NICs.  It appears it cannot handle reading the second NIC for
> some reason?

Errr, my bad.  The problem is more that the dual-port pro/1000 NICs
don't seem to work, but the built-in e1000s do.

The chipset that does not work correctly is: 82546GB

The NICs with chipset: 82541EI seem to work just fine.

Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
