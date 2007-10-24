From: David Miller <davem@davemloft.net>
Subject: on the topic of alternate MAC addresses
Date: Tue, 23 Oct 2007 18:05:34 -0700 (PDT)
Message-ID: <20071023.180534.59659315.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52244
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752546AbXJXBFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 21:05:07 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I've been meaning to bring this up.

A lot of cards that support multiple MAC addresses
in hardware provide pre-cooked lists of alternate
MAC addresses.  This is either done via EEPROM,
NVRAM, or OpenFirmware device properties.

For example, the Sun Neptune cards can provide an
array of up to 16 alternate MAC addresses per-port.

We should provide a way to export these lists to
userspace.

Perhaps an ethtool thing, Jeff?

Once we have this, virtualization implementations can probe for and
use them.  Currently they have no way to discover these things so
probably they just generate their own using some algorithm.
