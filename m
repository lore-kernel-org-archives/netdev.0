From: David Sterba <dave@jikos.cz>
Subject: Re: merging printk and WARN
Date: Mon, 5 Nov 2012 16:42:32 +0100
Message-ID: <20121105154232.GL3102@twin.jikos.cz>
References: <alpine.DEB.2.02.1211042120200.1960@localhost6.localdomain6>
Reply-To: dave@jikos.cz
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, airlied@linux.ie,
	netdev@vger.kernel.org, arnd@arndb.de, joern@logfs.org,
	chris.mason@fusionio.com, m@bues.ch, jejb@parisc-linux.org,
	faisal.latif@intel.com, neilb@suse.de, gregkh@linuxfoundation.org,
	JBottomley@parallels.com, swise@chelsio.com,
	achim_leubner@adaptec.com, tytso@mit.edu,
	dri-devel@lists.freedesktop.org, jason.wessel@windriver.com,
	kgdb-bugreport@lists.sourceforge.net,
	Prasad Joshi <prasadjoshi.linux@gmail.com>, logfs@logfs.org,
	linux-btrfs@vger.kernel.org, Helge Deller <deller@gmx.de>,
	linux-parisc@vger.kernel.org, Roland Dreier <roland@kernel.org>,
	Sean Hefty <sean.hefty@intel.com>, hal.rosenstock@gmail.com,
	linux-rdma@vger.kernel.org, linux-raid@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-scsi@vger.kernel.org,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	linux-ext4@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-ext4-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1211042120200.1960@localhost6.localdomain6>
Sender: linux-ext4-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 04, 2012 at 09:25:53PM +0100, Julia Lawall wrote:
> It looks like these patches were not a good idea, because in each case the
> printk provides an error level, and WARN then provides another one.

I think this is not a problem within btrfs at the place where this has
changed.

david
