From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.12-rc4] IPv4/IPv6: UDP Large Send Offload feature
Date: Fri, 27 May 2005 12:03:11 -0700 (PDT)
Message-ID: <20050527.120311.17863590.davem@davemloft.net>
References: <20050526232006.60E6365005@linux.site>
	<20050527085713.373d702a@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ravinandan.arakali@neterion.com, jgarzik@pobox.com, netdev@oss.sgi.com,
        raghavendra.koushik@neterion.com, leonid.grossman@neterion.com,
        ananda.raju@neterion.com, rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20050527085713.373d702a@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Fri, 27 May 2005 08:57:13 -0700

> The only downside is that it might encourage continued use of NFS over UDP.
> Perhaps we need a big fat warning in NFS that says:
> 
> *** Your using NFS over UDP, your data integrity is no longer guaranteed;
> *** you have been warned.

I agree, I think the NFS client should print out something
like this when it mounts a volume over UDP for the first
time.
