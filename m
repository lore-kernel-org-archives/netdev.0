From: Mike Fedyk <mfedyk@matchmail.com>
Subject: Fwd: Re: [2.6] nfs_rename: target $file busy, d_count=2
Date: Thu, 15 Jan 2004 17:22:40 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040116012240.GB1880@srv-lnx2600.matchmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

----- Forwarded message from Mike Fedyk <mfedyk@matchmail.com> -----

Date: Thu, 15 Jan 2004 16:54:57 -0800
From: Mike Fedyk <mfedyk@matchmail.com>
To: linux-kernel@vger.kernel.org
Subject: Re: [2.6] nfs_rename: target $file busy, d_count=2

On Thu, Jan 15, 2004 at 04:03:46PM -0800, Mike Fedyk wrote:
> Both client and server are running the same 2.6.1-bk2 kernel with TCP-NFS.
> SMP, Highmem, & preempt.

I have four clients that are all having this problem also, three 2.6, and
one 2.4 client.

Using TCP-NFS they all have stale nfs handles even after a reboot (only
rebooted one to try with 2.4.23), but changed one to UDP-NFS, and it didn't
have the stale handles.

Will do more testing with UDP-NFS.

Mike


----- End forwarded message -----
