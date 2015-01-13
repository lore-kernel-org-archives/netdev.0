From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv1 0/3 net-next] xen-netfront: refactor making Tx requests
Date: Tue, 13 Jan 2015 17:16:41 +0000
Message-ID: <1421169404-27461-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:10640 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752473AbbAMRUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 12:20:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As netfront as evolved to handle different sorts of skbs the code to
fill a Tx requests has been copy and pasted several times.  The series
refactors this and a few other areas.

The first patch is to a Xen header but this can be merged via
net-next.

David
