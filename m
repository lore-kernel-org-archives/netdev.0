From: David Brownell <david-b@pacbell.net>
Subject: Re: Linking interfaces to slots
Date: Fri, 03 Oct 2003 06:37:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F7D7B89.7090406@pacbell.net>
References: <3F7D675D.4000905@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Steve Modica <modica@sgi.com>
In-Reply-To: <3F7D675D.4000905@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Steve Modica wrote:
> 
> If one wanted to figure out which ethX was in which PCI slot on which 
> bus, what would be the most acceptable mechanism?  The drivers have 
> access to all this info, but then each driver would need some ioctl 
> added. Is there some more generic place in the kernel that could be 
> modified such that /proc/net/dev could hold this information?

On 2.6 there's /sys/class/net/ethX/device,
and ethtool_drvinfo.bus_info support should exist too...

- Dave
