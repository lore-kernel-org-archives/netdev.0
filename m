From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] panic during unregister_netdevice()
Date: Thu, 6 Nov 2003 13:14:57 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031106131457.384694a5.davem@redhat.com>
References: <20031106115935.0cd56745.davem@redhat.com>
	<Pine.LNX.4.44.0311061305550.1296-100000@DYN318430BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kumarkr@us.ibm.com, shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <krkumar@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0311061305550.1296-100000@DYN318430BLD.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 6 Nov 2003 13:07:57 -0800 (PST)
Krishna Kumar <krkumar@us.ibm.com> wrote:

> I tested with the following patch, and the panic disappeared (the
> device shutdown properly). Dave, any need for rtnl_unlock() in this
> code ?

This linkwatch code never generates new entries on the netdev todo
list so your patch looks fine.

I'm going to apply it, thanks a lot.
