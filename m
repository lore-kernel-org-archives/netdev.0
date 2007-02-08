From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Network: convert network devices to use struct device instead
 of class_device
Date: Thu, 08 Feb 2007 07:43:18 -0500
Message-ID: <45CB1AE6.9020707@garzik.org>
References: <200702080400.l1840lFd002314@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Greg KH <greg@kroah.com>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44813 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422975AbXBHMnV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Feb 2007 07:43:21 -0500
In-Reply-To: <200702080400.l1840lFd002314@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linux Kernel Mailing List wrote:
> Gitweb:     http://git.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=43cb76d91ee85f579a69d42bc8efc08bac560278
> Commit:     43cb76d91ee85f579a69d42bc8efc08bac560278
> Parent:     2943ecf2ed32632473c06f1975db47a7aa98c10f
> Author:     Greg Kroah-Hartman <gregkh@suse.de>
> AuthorDate: Tue Apr 9 12:14:34 2002 -0700
> Committer:  Greg Kroah-Hartman <gregkh@suse.de>
> CommitDate: Wed Feb 7 10:37:11 2007 -0800
> 
>     Network: convert network devices to use struct device instead of class_device
>     
>     This lets the network core have the ability to handle suspend/resume
>     issues, if it wants to.
>     
>     Thanks to Frederik Deweerdt <frederik.deweerdt@gmail.com> for the arm
>     driver fixes.
>     
>     Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
> ---
>  drivers/infiniband/ulp/ipoib/ipoib_main.c |   33 ++--
>  drivers/infiniband/ulp/ipoib/ipoib_vlan.c |   11 +-
>  drivers/net/arm/at91_ether.c              |    2 +-
>  drivers/net/arm/etherh.c                  |    2 +-
>  drivers/net/bonding/bond_sysfs.c          |  287 +++++++++++++++++-----------
>  drivers/net/iseries_veth.c                |    2 +-
>  drivers/net/macb.c                        |   36 ++--
>  drivers/net/smc911x.c                     |    2 +-
>  drivers/net/smc91x.c                      |    2 +-
>  drivers/net/wireless/hostap/hostap_main.c |    2 +-
>  drivers/net/wireless/orinoco.c            |    4 +-
>  drivers/net/wireless/orinoco_cs.c         |    2 +-
>  drivers/net/wireless/spectrum_cs.c        |    2 +-
>  include/linux/netdevice.h                 |    5 +-
>  net/bridge/br_if.c                        |    2 +-
>  net/bridge/br_sysfs_br.c                  |  234 +++++++++++++-----------
>  net/bridge/br_sysfs_if.c                  |    2 +-
>  net/core/dev.c                            |    6 +-
>  net/core/net-sysfs.c                      |  175 ++++++++++--------
>  net/core/skbuff.c                         |    2 +-
>  20 files changed, 451 insertions(+), 362 deletions(-)

It's highly disappointing that this was never discussed on 
netdev@vger.kernel.org, or even CC'd to me.

	Jeff


