From: Ben Greear <greearb@candelatech.com>
Subject: Re: e1000 driver problem with Intel Pro/1000 MT adapter
Date: Sun, 05 Dec 2004 00:37:19 -0800
Message-ID: <41B2C8BF.9050204@candelatech.com>
References: <200412032325.iB3NPdG04693@xos037.xos.nl> <1102204801.3343.68.camel@sfeldma-mobl.dsl-verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jos Vos <jos@xos.nl>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: sfeldma@pobox.com
In-Reply-To: <1102204801.3343.68.camel@sfeldma-mobl.dsl-verizon.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Scott Feldman wrote:
> On Fri, 2004-12-03 at 15:25, Jos Vos wrote:
> 
>>I have a problem with an Intel Pro/1000 MT 4-port card in a Supermicro
>>(non-HT) Pentium 4 system using RHEL3 (2.4.21 kernel "the RH way") with
>>the e1000 driver (I tried both the version supplied by RH and the
>>newest 5.5.4 driver):
> 
> 
> The 4-port card has two 82546 dual-port controllers behind a PCI-X
> bridge.  Your symptoms suggest interrupt routing didn't get setup
> correctly for the controllers behind the bridge.  I've seen more than
> one case where the BIOS gets this wrong.  The fix is to upgrade to the
> latest BIOS.  Hopefully this is the fix for you.  :-)

For what it's worth, I've had good luck with a 4-port pro/1000 NIC
in a SuperMicro X5-DPAGG (dual xeon, PCI-X) motherboard.  I've tried it with kernel
2.4.27 and 2.6.9 so far...  For maximum performance, I needed to increase
the tx and rx descriptors to 2k, I believe this helps mitigate the extra
latency caused by the PCI-X bridge on the NIC...

Ben

> 
> -scott
> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
