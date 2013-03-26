From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: Active URB submitted twice in pegasus driver
Date: Tue, 26 Mar 2013 17:22:07 +0200 (EET)
Message-ID: <alpine.DEB.2.02.1303261655450.3724@fry.nucleusys.com>
References: <20130325223834.GF6869@xanatos>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: Petko Manolov <petkan@users.sourceforge.net>,
	linux-usb@vger.kernel.org, Greg KH <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lan.nucleusys.com ([92.247.61.126]:60335 "EHLO
	zztop.nucleusys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965291Ab3CZPkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 11:40:33 -0400
In-Reply-To: <20130325223834.GF6869@xanatos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Mar 2013, Sarah Sharp wrote:

> Hi Petko,
>
> I'm testing a USB to ethernet adapter with Greg's usb-linus branch (based
> on 3.9-rc4).  I'm seeing an odd behavior, and I'm suspicious that a
> second behavior found by Stephen Hemminger may also be related:
>
> http://marc.info/?l=linux-usb&m=136364625519235&w=2
>
> When I load the pegasus driver for this adapter (without an ethernet
> cable hooked to it), and this is on a cold system boot or a complete
> unloading and reloading of the usbcore, I get the following warning:

Unfortunately the machine i ran my tests on does not have xHCI nor i used 
Greg's tree.  I did not observe this warning on both 3.8.4 and Linus' 
3.9-rc4.  It looks like to me that the issue is outside the driver code.

However, i am curious whether you experience the same problem with other 
(non-ADMtek based) usb-to-lan adapters which support xxx_set_multicast(). 
These calls are asynchronous by nature and should also trigger this 
warning.  Please let me know if this is not the case so i start digging 
into pegasus.c.



cheers,
Petko
