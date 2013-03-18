From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PULL] vhost: tcm_vhost fixes for 3.9
Date: Mon, 18 Mar 2013 21:54:43 +0200
Message-ID: <20130318195443.GB19761@redhat.com>
References: <20130318112003.GA7809@redhat.com>
 <20130318.130136.1629094222097780420.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	asias@redhat.com, nab@linux-iscsi.org, target-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130318.130136.1629094222097780420.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 18, 2013 at 01:01:36PM -0400, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Mon, 18 Mar 2013 13:20:03 +0200
> 
> > The following changes since commit 8c6216d7f118a128678270824b6a1286a63863ca:
> > 
> >   Revert "ip_gre: make ipgre_tunnel_xmit() not parse network header as IP unconditionally" (2013-03-16 23:00:41 -0400)
> > 
> > are available in the git repository at:
> > 
> >   git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost-net
> > 
> > for you to fetch changes up to deb7cb067dabd3be625eaf5495da8bdc97377fc1:
> > 
> >   tcm_vhost: Flush vhost_work in vhost_scsi_flush() (2013-03-17 13:04:14 +0200)
> 
> This is a scsi driver, I therefore don't think this pull request is for me.
> 
> Please avoid such confusion in the future, and don't use branch names
> like "vhost-net" for SCSI driver fixes.
> 
> Thanks.

We are sharing quite a bit of code, so it's a common tree.
There was a vhost-net patch there too but you picked it up
directly so I dropped that and what's left is vhost-scsi.
Typically vhost-net dominates so I'm just used to merging all vhost
things through you but if you think it's wrong I can send it directly to
Linus.

-- 
MST
