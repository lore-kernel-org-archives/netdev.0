From: Julia Lawall <julia.lawall@lip6.fr>
Subject: merging printk and WARN
Date: Sun, 4 Nov 2012 21:25:53 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1211042120200.1960@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: dri-devel@lists.freedesktop.org, jason.wessel@windriver.com,
	kgdb-bugreport@lists.sourceforge.net,
	Prasad Joshi <prasadjoshi.linux@gmail.com>, logfs@logfs.org,
	linux-btrfs@vger.kernel.org, Helge Deller <deller@gmx.de>,
	linux-parisc@vger.kernel.org, Roland Dreier <roland@kernel.org>,
	Sean Hefty <sean.hefty@intel.com>, hal.rosenstock@gmail.com,
	linux-rdma@vger.kernel.org, linux-raid@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-scsi@vger.kernel.org,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	linux-ext4@vger.kernel.org
To: linux-kernel@vger.kernel.org, airlied@linux.ie,
	netdev@vger.kernel.org, arnd@arndb.de, joern@logfs.org,
	chris.mason@fusionio.com, m@bues.ch, jejb@parisc-linux.org,
	faisal.latif@intel.com, neilb@suse.de, gregkh@linuxfoundation.org,
	JBottomley@parallels.com, swise@chelsio.com,
	achim_leubner@adaptec.com, swise@chelsio.com, tytso@mit.edu
Return-path: <linux-btrfs-owner@vger.kernel.org>
Sender: linux-btrfs-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It looks like these patches were not a good idea, because in each case the 
printk provides an error level, and WARN then provides another one.

Sorry for the noise.

julia
