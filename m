From: Stuart Hodgson <smhodgson@solarflare.com>
Subject: [PATCH 0/3] ethtool: Add command to dump and parse module EEPROM
Date: Fri, 18 May 2012 15:57:41 +0100
Message-ID: <4FB66365.4050007@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Yaniv Rosner <yanivr@broadcom.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:58849 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751642Ab2ERO5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 10:57:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These three patches add support for the new ETHTOOL_GMODULEINFO and 
ETHTOOL_GMODULEEEPROM commands in net-next.

The first patch splits duplicated code used to print hex data into a function
The second patch updates the the ethtool-copy.h from the net-next. 
The third implements the new commands. Support for parsing SFP 8079 compatible EEPROMs
has also be incorporated.

Stu
