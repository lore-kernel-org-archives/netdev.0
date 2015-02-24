From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net-next 00/10] pktgen documentation cleanup and samples
Date: Tue, 24 Feb 2015 02:30:19 +0000
Message-ID: <1424745019.4443.1.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:55211 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752239AbbBXCaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 21:30:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series cleans up the pktgen documentation, adds and improves the
original sample scripts.

Ben.

Ben Hutchings (10):
  pktgen: Delete the original date from documentation
  pktgen: Fix grammar errors and some poor wording in documentation
  samples/pktgen: Add sample scripts for pktgen facility
  samples/pktgen: Delete unused function pg()
  samples/pktgen: Correct comments about the thread config
  samples/pktgen: Remove setting of obsolete max_before_softirq
    parameter
  samples/pktgen: Use bash as interpreter
  samples/pktgen: Trap SIGINT
  samples/pktgen: Show the results rather than just commenting where
    they are
  pktgen: Correct documentation of module name and command

 Documentation/networking/pktgen.txt     |   62 +++++++++++++-------------
 samples/pktgen/pktgen.conf-1-1          |   59 +++++++++++++++++++++++++
 samples/pktgen/pktgen.conf-1-1-flows    |   67 ++++++++++++++++++++++++++++
 samples/pktgen/pktgen.conf-1-1-ip6      |   60 +++++++++++++++++++++++++
 samples/pktgen/pktgen.conf-1-1-ip6-rdos |   63 ++++++++++++++++++++++++++
 samples/pktgen/pktgen.conf-1-1-rdos     |   64 +++++++++++++++++++++++++++
 samples/pktgen/pktgen.conf-1-2          |   69 +++++++++++++++++++++++++++++
 samples/pktgen/pktgen.conf-2-1          |   66 ++++++++++++++++++++++++++++
 samples/pktgen/pktgen.conf-2-2          |   73 +++++++++++++++++++++++++++++++
 9 files changed, 553 insertions(+), 30 deletions(-)
 create mode 100755 samples/pktgen/pktgen.conf-1-1
 create mode 100755 samples/pktgen/pktgen.conf-1-1-flows
 create mode 100755 samples/pktgen/pktgen.conf-1-1-ip6
 create mode 100755 samples/pktgen/pktgen.conf-1-1-ip6-rdos
 create mode 100755 samples/pktgen/pktgen.conf-1-1-rdos
 create mode 100755 samples/pktgen/pktgen.conf-1-2
 create mode 100755 samples/pktgen/pktgen.conf-2-1
 create mode 100755 samples/pktgen/pktgen.conf-2-2

-- 
1.7.10.4
