From: Chuck Ebbert <cebbert@redhat.com>
Subject: nf_conntrack_max appears twice in /proc/sys/net
Date: Tue, 13 Nov 2007 14:46:47 -0500
Message-ID: <4739FF27.2040204@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:46033 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759228AbXKMTqt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 14:46:49 -0500
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.1) with ESMTP id lADJkmSj018798
	for <netdev@vger.kernel.org>; Tue, 13 Nov 2007 14:46:48 -0500
Received: from mail.boston.redhat.com (mail.boston.redhat.com [172.16.76.12])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id lADJklKG023729
	for <netdev@vger.kernel.org>; Tue, 13 Nov 2007 14:46:47 -0500
Received: from [172.16.83.145] (dhcp83-145.boston.redhat.com [172.16.83.145])
	by mail.boston.redhat.com (8.13.1/8.13.1) with ESMTP id lADJkljK018530
	for <netdev@vger.kernel.org>; Tue, 13 Nov 2007 14:46:47 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With 2.6.23.1:

# pwd ; find . -name nf_conntrack_max
/proc/sys/net
./netfilter/nf_conntrack_max
./nf_conntrack_max

Both sysctls operate on the same underlying value, though, so no real
problem.
