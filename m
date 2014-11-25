From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 0/7] kernel tinification: optionally compile out
 splice family of syscalls (splice, vmsplice, tee and sendfile)
Date: Tue, 25 Nov 2014 10:10:32 -0800
Message-ID: <20141125181032.GJ5050@linux.vnet.ibm.com>
References: <1416870079-15254-1-git-send-email-pieter@boesman.nl>
 <5474ABB6.3030400@infradead.org>
 <20141125.121305.2094097848188324942.davem@davemloft.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rdunlap@infradead.org, pieter@boesman.nl, josh@joshtriplett.org,
	alexander.h.duyck@intel.com, viro@zeniv.linux.org.uk,
	ast@plumgrid.com, akpm@linux-foundation.org, beber@meleeweb.net,
	catalina.mocanu@gmail.com, dborkman@redhat.com,
	edumazet@google.com, ebiederm@xmission.com, fabf@skynet.be,
	fuse-devel@lists.sourceforge.net, geert@linux-m68k.org,
	hughd@google.com, iulia.manda21@gmail.com, JBeulich@suse.com,
	bfields@fieldses.org, jlayton@poochiereds.net,
	linux-api@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	mcgrof@suse.com, mattst88@gmail.com, mgorman@suse.de,
	mst@redhat.com, miklos@szeredi.hu, netdev@vger.kernel.org,
	oleg@redhat.com, Paul.Durrant@citrix.com, pefoley2@pefoley.com,
	tgraf@suug.ch, therbert@google.com,
	trond.myklebust@primarydata.com, willemb@google.com,
	xiaoguangrong@linux.vnet.ibm.com, zhenglong
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141125.121305.2094097848188324942.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 25, 2014 at 12:13:05PM -0500, David Miller wrote:
> From: Randy Dunlap <rdunlap@infradead.org>
> Date: Tue, 25 Nov 2014 08:17:58 -0800
> 
> > Is the splice family of syscalls the only one that tiny has identified
> > for optional building or can we expect similar treatment for other
> > syscalls?
> > 
> > Why will many embedded systems not need these syscalls?  You know
> > exactly what apps they run and you are positive that those apps do
> > not use splice?
> 
> I think starting to compile out system calls is a very slippery
> slope we should not begin the journey down.
> 
> This changes the forward facing interface to userspace.

I certainly sympathize with this concern, given the importance of software
portability.  However, the tiny-hardware alternative appears ot some sort
of special-purpose embedded OS, which most definitely will suffer from
software compatibility issues.  I guess that the good news is that much
of the tiny hardware that used to be 8 or 16 bits is now 32 bits, which
means that it has at least some chance of running some form of Linux.  ;-)

							Thanx, Paul
