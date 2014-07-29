From: Marco Varlese <marco.varlese@gmail.com>
Subject: Port attributes configuration
Date: Tue, 29 Jul 2014 10:15:10 +0100
Message-ID: <CACWm-Bc4=4We1AfnZpL7O5VkUSKjKBZ-NK6edXW2fE5b_u-e7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:60849 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753071AbaG2JPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 05:15:11 -0400
Received: by mail-lb0-f172.google.com with SMTP id z11so6830139lbi.3
        for <netdev@vger.kernel.org>; Tue, 29 Jul 2014 02:15:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm working on a new platform and the network interfaces will have
quite few new options (roughly 50) to configure. What I definitely
want to achieve is to use the common tools available on Linux to let
users configure the port attributes from user-space without writing a
brand new ad-hoc tool.

Considered my requirements I think I've a choice of configuring these
port attributes via:
1) ethtool: this I guess will require patches to the tool itself plus
patches to the kernel to extend the IOCTL calls performed by it;
2) sysfs: adding new files under /sys/class/net/DEVICE/ and handle the
sysfs extensions in my kernel driver;
3) netlink: I understand this seems to be the path most people prefer
but I think it will require a new tool to be written?

What would you suggest as the best approach here to have a good
solution accepted by most?


Thanks,
Marco
