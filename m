From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net v4 0/1] xen-netback: windows frontend compatibility fixes
Date: Tue, 24 Sep 2013 16:44:59 +0100
Message-ID: <1380037500-12174-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:40815 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753927Ab3IXPpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 11:45:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patches fix a couple more issues found when testing with
Windows frontends.

v4:
- Fix problem with hotplug failure noticed by Wei Liu

v3:
- Collapse both v2 patches into a single patch that introduces a new
  function to handle backend state transtions. By doing this we ensure that
  we always transition through intermediate states and that we don't attempt
  repeated connects or disconnects.

v2:
- Add comment in 2/2 to note that state transitions from Connected to Closed
  are incorrect.
