From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 0/4] dev_open() and dev_close() require RTNL
Date: Tue, 6 May 2008 19:26:55 +0100
Message-ID: <20080506182654.GF2217@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:54011 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753203AbYEFS1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 14:27:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_open() and dev_close() clearly require the RTNL, but this isn't
commented or asserted.  The following series adds assertions and fixes
three drivers that call dev_close() without holding the RTNL.  The
driver changes are only compile-tested.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
