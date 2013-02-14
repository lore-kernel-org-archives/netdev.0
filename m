From: David Vrabel <david.vrabel@citrix.com>
Subject: xen-netback: fix oopes during shutdown and error handling
Date: Thu, 14 Feb 2013 13:18:56 +0000
Message-ID: <1360847938-11185-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Jan Beulich <jbeulich@suse.com>, Wei Liu <wei.liu@citrix.com>,
	<netdev@vger.kernel.org>
To: <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:47248 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757643Ab3BNNTY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2013 08:19:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two netback patches fix oopes that may occur during shutdown or
if a specific fatal error occurs.

They are stable candidants.

David
