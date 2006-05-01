From: Ben Greear <greearb@candelatech.com>
Subject: Re: VLAN subinterfaces, bridges and udev
Date: Mon, 01 May 2006 09:02:04 -0700
Message-ID: <445630FC.3030300@candelatech.com>
References: <20060430142929.GA8901@wonderland.linux.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:11909 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S932137AbWEAQCL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 May 2006 12:02:11 -0400
To: netdev@vger.kernel.org, md@Linux.IT
In-Reply-To: <20060430142929.GA8901@wonderland.linux.it>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marco d'Itri wrote:
> [Please Cc me, I am not subscribed to netdev.]
> 
> Can I rely on the presence of the $DEVPATH/driver symlink (e.g.
> /sys/class/net/eth0/driver) to check if a network interface is a "real"
> device insteaf of a VLAN or a bridge?

To distinguish I use a VLAN specific IOCTL (GET_VLAN_REALDEV_NAME_CMD).
If that IOCTL has no error, then it is a VLAN.

I don't know if there is a similar trick for bridges.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

