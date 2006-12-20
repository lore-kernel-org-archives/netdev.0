From: Stephen Hemminger <shemminger@osdl.org>
Subject: [patch 0/6] sky2 driver update (v1.11)
Date: Wed, 20 Dec 2006 13:06:32 -0800
Message-ID: <20061220210632.183204605@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:58156 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423150AbWLVAkd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Dec 2006 19:40:33 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patches are in order of severity. 1-3 are bug fixes, 4 is a cleanup
of the power state code, and 5 adds wake on lan support.

IMHO, it is bad security policy to allow wake on lan to enabled by default.
The sky2 driver doesn't do WOL until enabled with ethtool.

--
Stephen Hemminger <shemminger@osdl.org>

