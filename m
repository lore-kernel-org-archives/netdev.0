From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [Patch net-next] bonding: remove ifenslave.c from kernel source
Date: Tue, 28 May 2013 07:38:29 +0200
Message-ID: <20130528053829.GA3853@unicorn.suse.cz>
References: <1369705756-11171-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:52715 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932643Ab3E1Fic (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 May 2013 01:38:32 -0400
Content-Disposition: inline
In-Reply-To: <1369705756-11171-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 28, 2013 at 09:49:16AM +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> As Stephen proposed:
> Since bonding supports configuration via iproute (netlink) and sysfs, I think
> it is time to purge the old ifenslave code out of Documentation/networking
> and update the documentation.
> 
> Suggested-by: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Jay Vosburgh <fubar@us.ibm.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
...
> @@ -1183,8 +1149,8 @@ reboots, edit the appropriate file (/etc/init.d/boot.local or
>  modprobe bonding mode=balance-alb miimon=100
>  modprobe e100
>  ifconfig bond0 192.168.1.1 netmask 255.255.255.0 up
> -ifenslave bond0 eth0
> -ifenslave bond0 eth1
> +ip link set eth0 master bond0
> +ip link set eth1 master bond0

While cleaning up, we might replace the ifconfig here with ip as well.

Michal Kubecek
