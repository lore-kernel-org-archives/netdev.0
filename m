From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/17][pull request] Intel Wired LAN Driver Updates
 2014-11-21
Date: Sun, 23 Nov 2014 14:22:45 -0500 (EST)
Message-ID: <20141123.142245.265639173507456098.davem@davemloft.net>
References: <1416635708-4765-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35088 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751779AbaKWTWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2014 14:22:48 -0500
In-Reply-To: <1416635708-4765-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 21 Nov 2014 21:54:50 -0800

> This series contains updates to i40e and i40evf.

As Ben mentioned, patches #13 and #14 at a minimum need to add a NULL
check against 'indir' in the ethtool handlers in question.
