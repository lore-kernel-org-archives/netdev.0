From: Dan Williams <dcbw@redhat.com>
Subject: bridge interface initial carrier state
Date: Mon, 11 Feb 2013 14:01:55 -0600
Message-ID: <1360612915.8633.6.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38440 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759692Ab3BKUBz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2013 15:01:55 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r1BK1ta3010015
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 11 Feb 2013 15:01:55 -0500
Received: from [10.3.231.28] (vpn-231-28.phx2.redhat.com [10.3.231.28])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r1BK1tHG010979
	for <netdev@vger.kernel.org>; Mon, 11 Feb 2013 15:01:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm wondering if the initial carrier state of 'on' is intentional for a
bridge without ports; immediately after adding ports, the carrier is
recalculated and depends on the combined state of each port's carrier
and STP forwarding state.  So a userspace program attempting to decide
whether the bridge was usable or not has to look at both (a) how many
ports are available and (b) bridge carrier state, instead of just
looking at the bridge carrier state.

Dan
