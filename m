From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH repost for-3.9] pci: avoid work_on_cpu for nested SRIOV
 probes
Date: Sun, 14 Apr 2013 06:43:39 -0700
Message-ID: <20130414134339.GA3050@htj.dyndns.org>
References: <20130411153030.GA22743@redhat.com>
 <20130411180517.GJ17641@mtj.dyndns.org>
 <20130411185853.GE23301@redhat.com>
 <20130411190408.GM17641@mtj.dyndns.org>
 <20130411191717.GB25515@redhat.com>
 <20130411192005.GN17641@mtj.dyndns.org>
 <20130411203053.GC25515@redhat.com>
 <20130411204104.GC11956@mtj.dyndns.org>
 <516AA80F.7040505@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Ming Lei <ming.lei@canonical.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Roland Dreier <roland@kernel.org>,
	netdev <netdev@vger.kernel.org>, Yan Burman <yanb@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <516AA80F.7040505@mellanox.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 14, 2013 at 03:58:55PM +0300, Or Gerlitz wrote:
> So the patch eliminated the lockdep warning for mlx4 nested probing
> sequence, but introduced lockdep warning for
> 00:13.0 PIC: Intel Corporation 7500/5520/5500/X58 I/O Hub I/OxAPIC
> Interrupt Controller (rev 22)

Oops, the patch in itself doesn't really change anything.  The caller
should use a different subclass for the nested invocation, just like
spin_lock_nested() and friends.  Sorry about not being clear.
Michael, can you please help?

Thanks.

-- 
tejun
