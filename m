From: "SangOg Na" <nso@pentamedia.com>
Subject: How can I disable ipv6 module only for oneway DVB receiving card?
Date: Tue, 23 May 2006 14:59:25 +0900
Message-ID: <085201c67e2e$0f353b20$3047efcb@nsowork>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="ks_c_5601-1987";
	reply-type=original
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.239.71.1] ([203.239.71.1]:57996 "EHLO ns.pentamedia.com")
	by vger.kernel.org with ESMTP id S1751349AbWEWGBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 02:01:36 -0400
Received: from nsowork ([203.239.71.48])
	(authenticated)
	by ns.pentamedia.com (8.11.6/8.11.6) with ESMTP id k4N5t6H14671
	for <netdev@vger.kernel.org>; Tue, 23 May 2006 14:55:06 +0900
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

I am porting pentavalue driver to kernel 2.6.
But when unload module, the following messages are displayed
and I can't unload it.

unregister_netdevice: waiting for pentaval0 to become free. Usage count = 5
unregister_netdevice: waiting for pentaval0 to become free. Usage count = 5

I insert printk("refcnt=%d\n,atomic_read(&dev->refcnt)); at dev_hold and 
dev_put
in include/linux/netdevice.h, and I found ipv6 module increase refcnt at 3 
times,
but at unloading module, decrease one only one time.

I built linux kernel no ipv6, refcnt problem did not occur.

Can I disable ipv6 only for my pentaval driver?

Test kernel version is 2.6.15.

Bye! 

