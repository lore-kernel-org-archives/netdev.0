From: bert hubert <ahu@ds9a.nl>
Subject: Re: [PATCH 2.6] vlan ioctl propagation (rev.2)
Date: Sun, 8 Aug 2004 12:14:21 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040808101421.GA22507@outpost.ds9a.nl>
References: <20040806091305.4d405664@dell_ss3.pdx.osdl.net> <20040806132145.675fd17d.davem@redhat.com> <20040806143928.711d92eb@dell_ss3.pdx.osdl.net> <20040807211036.GA7970@outpost.ds9a.nl> <4115AE4C.2060608@aarnet.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Glen Turner <glen.turner@aarnet.edu.au>
Content-Disposition: inline
In-Reply-To: <4115AE4C.2060608@aarnet.edu.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Aug 08, 2004 at 02:08:36PM +0930, Glen Turner wrote:

>    while (virtual_interface(interface_name)) {
>      virtual_to_real(interface_name, &interface_name);
>    }
> 
> This is the sort of nasty detail than operating systems are meant to
> abstract away from application code.

What I'm saying is that even userspace should not offer this abstraction.
Remember the past confusion over "ifconfig eth0:1 down" ?

But I'm more than prepared to follow DaveM's lead here, I just want to be
sure people think about this change.

Regards,

bert 

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
