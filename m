From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6.12-rc4] IPv4/IPv6: UDP Large Send Offload feature
Date: Fri, 27 May 2005 08:57:13 -0700
Message-ID: <20050527085713.373d702a@dxpl.pdx.osdl.net>
References: <20050526232006.60E6365005@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jgarzik@pobox.com, netdev@oss.sgi.com,
        raghavendra.koushik@neterion.com, ravinandan.arakali@neterion.com,
        leonid.grossman@neterion.com, ananda.raju@neterion.com,
        rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ravinandan.arakali@neterion.com
In-Reply-To: <20050526232006.60E6365005@linux.site>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 26 May 2005 16:20:06 -0700 (PDT)
ravinandan.arakali@neterion.com wrote:

> Hi,
> Attached below is a kernel patch to provide UDP LSO(Large Send Offload) 
> feature.
> This is the UDP counterpart of TSO. Basically, an oversized packet
> (less than or equal to 65535) is handed to the NIC. The adapter then
> produces IP fragments in conformance with RFC791(IPv4) or RFC2460(IPv6).
> 
> Very much like TCP TSO, UDP LSO provides significant reduction in CPU 
> utilization, especially with 1500 MTU frames. For 10GbE traffic,
> these extra CPU cycles translate into significant throughput increase 
> on most server platforms.
> 
> Reasonable amount of testing has been done on the patch using Neterion's
> 10G Xframe-II adapter to ensure code stability.
> 
> Please review the patch.
> 
> Also, below is a "how-to" on changes required in network drivers to use
> the UDP LSO interface.

The only downside is that it might encourage continued use of NFS over UDP.
Perhaps we need a big fat warning in NFS that says:

*** Your using NFS over UDP, your data integrity is no longer guaranteed;
*** you have been warned.
