From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 0/2] ethtool: enable a smaller build
Date: Wed, 26 Feb 2014 17:35:09 -0800
Message-ID: <1393464911-21593-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Florian Fainelli <f.fainelli@gmail.com>
To: <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:63695 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753531AbaB0BfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 20:35:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

This patchset fixes a missing entry in .gitignore and adds a new
option to the configure script to produced a smaller ethtool executable
(saves about 65% of its size) by disabling register and EEPROM dumps
pretty printing.

Florian Fainelli (2):
  gitignore: ignore test-driver
  ethtool: allow for a smaller build

 .gitignore   | 1 +
 Makefile.am  | 6 +++++-
 configure.ac | 8 ++++++++
 ethtool.c    | 8 ++++++--
 4 files changed, 20 insertions(+), 3 deletions(-)

-- 
1.8.3.2
