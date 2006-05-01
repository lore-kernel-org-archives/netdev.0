From: md@Linux.IT (Marco d'Itri)
Subject: Re: VLAN subinterfaces, bridges and udev
Date: Mon, 1 May 2006 21:43:19 +0200
Message-ID: <20060501194319.GD14523@wonderland.linux.it>
References: <20060430142929.GA8901@wonderland.linux.it> <445630FC.3030300@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from attila.bofh.it ([213.92.8.2]:26566 "EHLO attila.bofh.it")
	by vger.kernel.org with ESMTP id S932203AbWEATnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 May 2006 15:43:49 -0400
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <445630FC.3030300@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On May 01, Ben Greear <greearb@candelatech.com> wrote:

> >Can I rely on the presence of the $DEVPATH/driver symlink (e.g.
> >/sys/class/net/eth0/driver) to check if a network interface is a "real"
> >device insteaf of a VLAN or a bridge?
> To distinguish I use a VLAN specific IOCTL (GET_VLAN_REALDEV_NAME_CMD).
> If that IOCTL has no error, then it is a VLAN.
This is not useful for udev, it needs something available in sysfs.

-- 
ciao,
Marco
