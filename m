From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Tue, 06 May 2014 13:17:58 -0700
Message-ID: <1399407478.15399.81.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1399328773-6531-9-git-send-email-andi@firstfloor.org>
	 <20140505.231229.136734008603421707.davem@davemloft.net>
	 <20140506032114.GP2382@two.firstfloor.org>
	 <20140505.232327.578134514220748085.davem@davemloft.net>
	 <20140506155703.GA20391@cloud>
	 <1399394359.15399.20.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140506183216.GM19657@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: josh@joshtriplett.org, David Miller <davem@davemloft.net>,
	andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com
To: Andi Kleen <ak@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140506183216.GM19657@tassilo.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-05-06 at 11:32 -0700, Andi Kleen wrote:
> > We simply can not compete with user space, as a programmer is free to
> > keep what he really wants/needs.
> 
> Not true.

You can shake the kernel as much as you want, you wont make :
- a TCP socket
- a dentry
- an inode
- a file structure
- eventpoll structures (assuming epoll use)
- 2 dst per flow.

In 1024 bytes of memory, and keep an efficient kernel to handle
arbitrary number of sockets using the venerable and slow BSD socket api.

I was objecting to the "crazy things like LWIP" comment from Josh, not
to your patches in general.

I actually took a look at them but stopped at patch 22

Adding ~1000 lines of code to save few KB was the point I gave up.
