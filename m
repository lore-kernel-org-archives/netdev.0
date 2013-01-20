From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 19/21] ntb_netdev: declare unused variables and fix
 missing initializer
Date: Sun, 20 Jan 2013 15:47:56 -0800
Message-ID: <20130120234756.GB21708@kroah.com>
References: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
 <1358586155-23322-20-git-send-email-jon.mason@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Jon Mason <jon.mason@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1358586155-23322-20-git-send-email-jon.mason@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 19, 2013 at 02:02:33AM -0700, Jon Mason wrote:
> Tag qp in ntb_netdev_tx_handler and net_device in ntb_get_settings as
> unused function parameters.  Also, correct missing initializer errors
> for 'struct device_driver' in ntb_netdev_client.  This corrects issues
> found by 'EXTRA_CFLAGS=-W'.

Again, why would you want to ever build the kernel with that option?
This shouldn't be needed.

greg k-h
