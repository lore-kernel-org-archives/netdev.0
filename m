From: Andi Kleen <ak@suse.de>
Subject: Re: Ethernet bridge performance
Date: Sun, 10 Aug 2003 21:47:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030810194723.GA14822@wotan.suse.de>
References: <3F3217E7.2080903@allot.com> <3F3284EA.5050406@candelatech.com> <3F328A0F.3040005@allot.com> <16178.41976.3643.584516@robur.slu.se> <3F3601F3.6000001@allot.com> <3F368B3A.3070009@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Felix Radensky <felix@allot.com>,
   Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com,
   "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <3F368B3A.3070009@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> >Speaking of checksumming. This can be a problem indeed. ethtool -S shows 
> >a lot
> >of rx_csum_offload errors. Scott, what could possibly be a problem ? The 
> >NIC
> >is dual port 82546, driver is 5.1.13-k1.
> 
> Why would a bridge be checksumming anything?

A NIC normally checksums every incoming packet when hardware checksumming
is enabled.  But of course the bridge doesn't use that information.

-Andi
