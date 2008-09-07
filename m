From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: Re: add/delete VLANs programatically
Date: Sun, 7 Sep 2008 14:30:26 +0300
Message-ID: <20080907113026.GA13354@mtls03>
References: <20080907071246.GA12270@mtls03> <b25312890809070358t6a4b7296x778c2de01412ab6e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Rami Rosen <roszenrami@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:46115 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753185AbYIGL3x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Sep 2008 07:29:53 -0400
Content-Disposition: inline
In-Reply-To: <b25312890809070358t6a4b7296x778c2de01412ab6e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 07, 2008 at 01:58:20PM +0300, Rami Rosen wrote:

Hi Rami.

V> Hi,
>   -It seems to me that it is possible.
> 
>   - If  you look at the ordinary way in which user space add/deletes
> VLAN, you will see that this is performed by ioctls (SIOCSIFVLAN for
> adding /removing with ADD_VLAN_CMD or DEL_VLAN_CMD).
> - It is in performed by user space vconfig - VLAN (802.1q)
> configuration program.
> 
> - When looking  at how these IOCTLs are handled in the kernel, you
> will see that this is done by  vlan_ioctl_handler() in net/8021q/vlan.c.
> 
>  -If you look there, you will see that eventually adding a vlan is
> done in the kernel by
> register_vlan_device(net_device, VLAN ID);
> end deleing a vlan is done in the kernel by calling
> unregister_vlan_dev(net_device)
> 
> So it seems to me possible, though I did not try it.
I saw these functions but they're not exported to kernel modules so it
seems that I won't be able to use them from a kernel module.

