From: Mike Fedyk <mfedyk@matchmail.com>
Subject: Re: [2.6] nfs_rename: target $file busy, d_count=2
Date: Thu, 15 Jan 2004 18:45:55 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040116024555.GC1880@srv-lnx2600.matchmail.com>
References: <20040116000346.GD1784@srv-lnx2600.matchmail.com> <20040116005457.GE1784@srv-lnx2600.matchmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20040116005457.GE1784@srv-lnx2600.matchmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jan 15, 2004 at 04:54:57PM -0800, Mike Fedyk wrote:
> On Thu, Jan 15, 2004 at 04:03:46PM -0800, Mike Fedyk wrote:
> > Both client and server are running the same 2.6.1-bk2 kernel with TCP-NFS.
> > SMP, Highmem, & preempt.
> 
> I have four clients that are all having this problem also, three 2.6, and
> one 2.4 client.
> 
> Using TCP-NFS they all have stale nfs handles even after a reboot (only
> rebooted one to try with 2.4.23), but changed one to UDP-NFS, and it didn't
> have the stale handles.
> 
> Will do more testing with UDP-NFS.

No, TCP and UDP NFS both get stale file handles. :(

Can anyone reproduce?
