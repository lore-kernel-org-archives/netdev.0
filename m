From: Jeff Garzik <jgarzik@mandrakesoft.com>
Subject: Re: [ANNOUNCE] NAPI patches for 2.4.19-rc1
Date: Thu, 11 Jul 2002 10:37:10 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <3D2D9816.1050703@mandrakesoft.com>
References: <20020710223237.GA7995@orr.falooley.org> <Pine.GSO.4.30.0207101917480.22734-100000@shell.cyberus.ca> <20020711132604.GC12354@orr.falooley.org> <3D2D8A77.8060401@mandrakesoft.com> <20020711134432.GA12722@orr.falooley.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Jason Lunz <lunz@falooley.org>
List-Id: netdev.vger.kernel.org

Jason Lunz wrote:
> On Thu, Jul 11, 2002 at  9:39AM -0400, Jeff Garzik wrote:
> 
>>Yes, MMIO will speed up pretty much any tulip card
> 
> 
> Why isn't it the default? Because the clones don't handle it?


tulip still has PCI posting bugs [1], and some clones don't support MMIO 
at all.

	Jeff



[1] you only notice this on a few chipsets, typically non-ia32 ones
