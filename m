From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [0/9] pohmelfs: The Great Southern Trendkill release.
Date: Sun, 28 Dec 2008 16:53:31 +0300
Message-ID: <20081228135331.GC858@ioremap.net>
References: <1230301130-1325-1-git-send-email-zbe@ioremap.net> <20081226192618.GC1761@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <zbe@ioremap.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, pohmelfs@ioremap.net,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Pavel Machek <pavel@suse.cz>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081226192618.GC1761@ucw.cz>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pavel.

On Fri, Dec 26, 2008 at 08:26:19PM +0100, Pavel Machek (pavel@suse.cz) wrote:
> > POHMELFS is a kernel client for the developed distributed parallel internet
> > filesystem. As it exists today, it is a high-performance parallel network
> > filesystem with ability to balance reading from multiple hosts and simultaneously
> > write data to multiple hosts.
> 
> So ocfs2 -alike fs?

I think POHMELFS is more like pNFS now (yet), kernel client does not
get into similar to ocfs distributed facilities. POHMELFS server is
rather simple right now and when it will be ready with own distributed
design it will be very different from what we have in kernel.
Distributed processing engine is being built with distributed hash
table design in mind, so there will be no need for any kind of
metadata servers, locking daemons or special node management controls.

> > Signed-off-by: Evgeniy Polyakov <zbr@ioremap.net>
> 
> Do you think its ready for -mm?
> 
> Can it survive test such as paralel kernel compilation(s), fsx, etc?

I did not run fsx but kernel compilations, iozone, bonnie and the like
benchmarks run without any problems on the mounted partitions in my
test lab. There will be some extensions to the network protocol (mainly
new commands to force client to connect to the diferent server when
current one asks for that), but except that I do not have any
additional complex extensions in design. So I consider this kernel
client as mostly ready.

> How fast is it compared to nfs? to ext3 over fast network?

I ran really lots of tests and POHMELFS performance is frequently way
ahead of what async NFS provides, but this of course depends on the
final workload and probably may have some drawbacks found.

Links with graphs and numbers were sent in the another mail.

-- 
	Evgeniy Polyakov
