From: Greg KH <greg@kroah.com>
Subject: Re: Recent wireless breakage (ipw2200, iwconfig, NetworkManager)
Date: Sun, 4 Mar 2007 17:16:25 -0800
Message-ID: <20070305011625.GA7681@kroah.com>
References: <20070304220857.GH23311@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	yi.zhu@intel.com, jketreno@linux.intel.com
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:39455 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751276AbXCEBRN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Mar 2007 20:17:13 -0500
Content-Disposition: inline
In-Reply-To: <20070304220857.GH23311@waste.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 04, 2007 at 04:08:57PM -0600, Matt Mackall wrote:
> Recent kernels are having troubles with wireless for me. Two seemingly
> related problems:
> 
> a) NetworkManager seems oblivious to the existence of my IPW2200
> b) Manual iwconfig waits for 60s and then reports:
> 
> Error for wireless request "Set Encode" (8B2A) :
>     SET failed on device eth1 ; Operation not supported.

Do you have CONFIG_SYSFS_DEPRECATED enabled?  If not, please do as that
will keep you from having to change any userspace code.

thanks,

greg k-h
