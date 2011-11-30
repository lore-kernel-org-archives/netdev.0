From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [MAC802154] DRAFT: IEEE 802.15.4 MAC layer basic implementation
Date: Wed, 30 Nov 2011 17:18:27 +0300
Message-ID: <20111130141827.GA3739@avtobot.cybertron>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	davem@davemloft.net, alex.bluesman.smirnov@gmail.com
To: dbaryshkov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:33889 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751416Ab1K3NSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 08:18:40 -0500
Received: by eaak14 with SMTP id k14so656624eaa.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 05:18:39 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,

The IEEE 802.15.4 Working Group focuses on the standardization of the
bottom two layers of ISO/OSI protocol stack: Physical (PHY) and MAC.
The MAC layer provides access control to a shared channel and reliable
data delivery. The main functions performed by the MAC sublayer are:
association and disassociation, security control, optional star
network topology functions, such as beacon generation and Guaranteed
Time Slots (GTSs) management, generation of ACK frames (if used), and,
finally, application support for the two possible network topologies
described in the standard.

This stack has working implementation in 'linux-zigbee.sourceforge.net'
project, but unfortunately all the development was freezed according to
unknown issue and it hasn't been merged to mailnline.

Currently I'm the one engineer who continue working on them. So the
following patch series is based on the project mentioned above, and I just
cut code into roudimentary pieces with minor fixes.

The code in the following patches was tested by 6LowPAN module. I took at230
transciever driver from 'linux-zigbee' and brought up IPv6 network, it worked.

Could please anyone review patches and let me know what do you think?

With best regards,
Alexander Smirnov
