From: James Morris <jmorris@namei.org>
Subject: Refactor Netlink connector?
Date: Fri, 26 May 2006 16:04:53 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605261552570.4856@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:20389 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751413AbWEZUEz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 May 2006 16:04:55 -0400
Received: from megaweapon.nightmoose.net (HELO d.namei) ([66.92.66.197])
          (envelope-sender <jmorris@namei.org>)
          by mail5.sea5.speakeasy.net (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 26 May 2006 20:04:54 -0000
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've been looking through the kernel for new subsytems which might need 
LSM hooks, and we've got a proliferation of Netlink abstractions: generic 
Netlink, nfnetlink, connector and kobject_uevent.

I think we should look at consolidating some of these schemes, and if 
possible, into a unififed Netlink API.

As a first step, what would it take to adapt the single user of 
connector (the w1 driver) to use generic Netlink?

I suspect that some of the nfnetlink infrastructure can be used more 
generically, and that a simple API for the common case of kernel->user 
event notifications could be also be provided.

Thoughts?


- James
-- 
James Morris
<jmorris@namei.org>
