From: Baruch Even <baruch@ev-en.org>
Subject: Re: [PATCH 2/5] TCP BIC 1.1 support
Date: Sat, 19 Mar 2005 02:53:09 +0000
Message-ID: <423B9415.2010906@ev-en.org>
References: <20050318162211.366ca490@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@digeo.com>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com, Injong Rhee <rhee@eos.ncsu.edu>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050318162211.366ca490@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> This patch adds TCP BIC back in as a pluggable TCP congestion mechanism.
> This version is closer to the TCP BIC 1.1 released for Web100.
> The changes from 2.6.11 are:
> 	* congestion window undo fix
> 	* delayed ack compensation

This can cause overshooting if the other side doesn't do delayed acking, 
did anyone consider the ABC (Appropriate Byte Counting) patch from 
Yee-Ting Li? 
http://marc.theaimsgroup.com/?l=linux-netdev&m=110917262615630&w=2

FreeBSD has an option to disable delayed acking so it's not that hard to 
work against a host with no delayed acks at all.

> +		/* slow start AMD linear increase */

AIMD maybe?

Baruch
