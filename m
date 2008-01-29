From: Mitch Williams <mitch.a.williams@intel.com>
Subject: [PATCH 0/3]  Add flexible wake filter support
Date: Tue, 29 Jan 2008 13:02:03 -0800
Message-ID: <1201640523.11148.31.camel@strongmad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:59626 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755442AbYA2VSQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2008 16:18:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds support for Wake-on-Lan flexible filters to ethtool
and to e1000e.  Since this hardware feature is required for
certification on Another Operating System(TM), it's likely that most
current hardware supports it in one form or another.

To set a filter:
$ ethtool -F ethx <filter num> <filter spec>
  where <filter spec> is a string of hex digits (or xx for ignore)
describing bytes from the beginning of the expected packet.
For example:  $ ethtool -F eth0 0 00a055667788xxxx449976xx32

To show a filter:
$ ethtool -f ethx <filter num>

This feature gives more wakeup flexibility for people who need it.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>


