From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipip, sit: copy parms.name after register_netdevice
Date: Sat, 10 Dec 2011 13:12:28 -0500 (EST)
Message-ID: <20111210.131228.456749220758392202.davem@davemloft.net>
References: <20111207.235602.1465915988125994516.davem@davemloft.net>
	<20111208104619.GA20150@ted-OptiPlex-380>
	<20111210142920.GA3988@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: artisdom@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111210142920.GA3988@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ted Feng <artisdom@gmail.com>
Date: Sat, 10 Dec 2011 22:29:24 +0800

> On Thu, Dec 08, 2011 at 06:46:21PM +0800, Ted Feng wrote:
>> From: Ted Feng <artisdom@gmail.com>
>> 
>> Same fix as 731abb9cb2 for ipip and sit tunnel.
>> Commit 1c5cae815d removed an explicit call to dev_alloc_name in
>> ipip_tunnel_locate and ipip6_tunnel_locate, because register_netdevice
>> will now create a valid name, however the tunnel keeps a copy of the
>> name in the private parms structure. Fix this by copying the name back
>> after register_netdevice has successfully returned.
>> 
> Just a reminder. The previous resubmited patch got no response.

So?  It's queued up in patchwork:

http://patchwork.ozlabs.org/project/netdev/list/

and therefore will get looked at when someone finds the time.
