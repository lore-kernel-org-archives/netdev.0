From: sfeldma@gmail.com
Subject: [PATCH net-next 0/4] switchdev: documentation updates
Date: Wed,  3 Jun 2015 20:43:39 -0700
Message-ID: <1433389423-58467-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34264 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751043AbbFDDln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 23:41:43 -0400
Received: by payr10 with SMTP id r10so20449308pay.1
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 20:41:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Update the switchdev documentation to clarify that for IPV4 FIB object, the add
op is used for both adding and modifying the FIB entry on the device.

I found a few other white-space and grammer issues to fix, and to clarify the
static FDB ops.

Scott Feldman (4):
  switchdev: documentation: fix longer-than-80-char lines
  switchdev: documentation: fix grammer error
  switchdev: documentation: for static FDB ops, use
    switchdev_port_fdb_xxx ops
  switchdev: documentation: use switchdev_port_obj_xxx for IPv4 FIB
    add/modify/delete ops

 Documentation/networking/switchdev.txt |   95 +++++++++++++++++---------------
 net/switchdev/switchdev.c              |    4 +-
 2 files changed, 54 insertions(+), 45 deletions(-)

-- 
1.7.10.4
