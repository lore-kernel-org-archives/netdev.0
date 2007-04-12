From: David Howells <dhowells@redhat.com>
Subject: Getting a network interface list from within the kernel
Date: Thu, 12 Apr 2007 21:51:50 +0100
Message-ID: <2970.1176411110@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52228 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753622AbXDLUwE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2007 16:52:04 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l3CKq1YR018712
	for <netdev@vger.kernel.org>; Thu, 12 Apr 2007 16:52:01 -0400
Received: from warthog.cambridge.redhat.com (warthog.cambridge.redhat.com [172.16.18.73])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l3CKptI7006836
	for <netdev@vger.kernel.org>; Thu, 12 Apr 2007 16:51:56 -0400
Received: from redhat.com (localhost.localdomain [127.0.0.1])
	by warthog.cambridge.redhat.com (8.13.8/8.13.8) with ESMTP id l3CKpold002971
	for <netdev@vger.kernel.org>; Thu, 12 Apr 2007 21:51:52 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I need to get a list of the IPv4 addresses bound to network interfaces from
within the kernel to be able to present it to an AFS server when it asks.
This is handled by the AFS client filesystem.

I also need to be able to get the netmasks and MTUs for those interfaces.

What's the best way of doing this, assuming it's possible at all?

David
