From: Chuck Ebbert <cebbert@redhat.com>
Subject: qla3xxx network driver fills the log with "Link is down" messages
Date: Mon, 20 Oct 2008 18:48:15 -0400
Message-ID: <20081020184815.5e9ca743@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:46809 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755219AbYJTWsS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Oct 2008 18:48:18 -0400
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id m9KMmH9R009338
	for <netdev@vger.kernel.org>; Mon, 20 Oct 2008 18:48:17 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id m9KMmGtF017163
	for <netdev@vger.kernel.org>; Mon, 20 Oct 2008 18:48:17 -0400
Received: from localhost.localdomain (dhcp-100-2-144.bos.redhat.com [10.16.2.144])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id m9KMmGDi006873
	for <netdev@vger.kernel.org>; Mon, 20 Oct 2008 18:48:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

https://bugzilla.redhat.com/show_bug.cgi?id=461623

If you try to bring up a qla3xxx adapter without any cable connected 
it fills the log with:

qla3xxx eth2: Link is down.
qla3xxx eth2: port_link_state = LS_DOWN.
qla3xxx eth2: Link is down.
qla3xxx eth2: port_link_state = LS_DOWN.
qla3xxx eth2: Link is down.
qla3xxx eth2: port_link_state = LS_DOWN.
qla3xxx eth2: Link is down.
qla3xxx eth2: port_link_state = LS_DOWN.
...

