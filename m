From: James Feeney <james@nurealm.net>
Subject: feature - ip link set <dev> primary <dev> ?
Date: Thu, 4 Feb 2016 20:07:53 -0700
Message-ID: <56B41209.1060308@nurealm.net>
Reply-To: james@nurealm.net
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from resqmta-po-11v.sys.comcast.net ([96.114.154.170]:39001 "EHLO
	resqmta-po-11v.sys.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751426AbcBEDQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 22:16:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Should there be an

 ip link set <primary-slave-device> primary <master-device>

command in the iproute2 package, to set the Primary Slave on a "bond" type link?

It seems that the alternative now is to use the sysfs, with

 echo -n <primary> > /sys/devices/virtual/net/<master-device>/bonding/primary

which, in systemd Service Unit Files, requires "/usr/bin/sh -c 'echo ...'"
rather than simply "/usr/bin/echo ...".  "ip" seems to handle all other "bond"
configuration itself.

Thanks
James
