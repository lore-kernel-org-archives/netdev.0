From: Stephen Wadeley <swadeley@redhat.com>
Subject: bonding.txt, broadcast mode description
Date: Wed, 04 Mar 2015 21:49:50 +0100
Message-ID: <54F76FEE.1050002@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62492 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751625AbbCDUtw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Mar 2015 15:49:52 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t24KnqFh020626
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 4 Mar 2015 15:49:52 -0500
Received: from [10.40.204.36] ([10.40.204.36])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t24KnolY023646
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 4 Mar 2015 15:49:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Esteemed List Members

In my private time I work on Fedora guides and I would like to 
contribute something to kernel docs and networking related man pages.

WRT doc/Documentation/networking/bonding.txt


under bonding, modes, there is currently:

	broadcast or 3

		Broadcast policy: transmits everything on all slave
		interfaces.  This mode provides fault tolerance.

How do the list members feel about changing that to:

Option 1]
Broadcast policy: All transmissions are sent on all slave interfaces. 
Useful for high availability applications where duplicate packets are 
sent to separate networks. Requires switch support if sending to a 
single network.

Option 2]
Broadcast policy: All transmissions are sent
on all slave interfaces. Useful for high availability applications where
duplicate packets are sent to separate networks. Requires switch support
if sending to a single network. This mode might not work behind a bridge
with virtual machines without additional switch configuration.


Willing to submit patches.

Thank you
Yours sincerely

-- 
Stephen Wadeley
Content Author | Red Hat, Inc.
Purkynova 99 | Brno, Czech Republic
