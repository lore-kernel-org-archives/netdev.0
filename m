From: Patrick Mau <mau@oscar.ping.de>
Subject: Re: Fwd: Re: [2.6] nfs_rename: target $file busy, d_count=2
Date: Fri, 16 Jan 2004 14:03:36 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040116130336.GA5220@oscar.prima.de>
References: <20040116050642.GF1748@srv-lnx2600.matchmail.com>
Reply-To: Patrick Mau <mau@oscar.ping.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mike Fedyk <mfedyk@matchmail.com>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040116050642.GF1748@srv-lnx2600.matchmail.com>
List-Id: netdev.vger.kernel.org

On Thu, Jan 15, 2004 at 09:06:42PM -0800, Mike Fedyk wrote:
> On Thu, Jan 15, 2004 at 04:54:57PM -0800, Mike Fedyk wrote:
> > On Thu, Jan 15, 2004 at 04:03:46PM -0800, Mike Fedyk wrote:
> > > Both client and server are running the same 2.6.1-bk2 kernel with TCP-NFS.
> > > SMP, Highmem, & preempt.
> > 
> > I have four clients that are all having this problem also, three 2.6, and
> > one 2.4 client.
> > 
> > Using TCP-NFS they all have stale nfs handles even after a reboot (only
> > rebooted one to try with 2.4.23), but changed one to UDP-NFS, and it didn't
> > have the stale handles.
> > 
> > Will do more testing with UDP-NFS.
> 
> No, TCP and UDP NFS both get stale file handles. :(
> 
> Can anyone reproduce?

Hi,

I was able to reproduce stale handles a long time ago.
A workable solution for me was to export using 'no_subtree_check'
on the server. Like this:

/data \
  tony.local.net(rw,sync,no_root_squash,no_subtree_check) \

Could you please try and reply to my address if t works ?

Thanks,
Patrick
