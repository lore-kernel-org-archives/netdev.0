From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] ulogd 2.0.1 release
Date: Mon, 8 Oct 2012 14:15:35 +0200
Message-ID: <20121008121535.GA27399@1984>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="sdtB3X0nJg68CQEu"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41685 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750845Ab2JHMPk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2012 08:15:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--sdtB3X0nJg68CQEu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        ulogd 2.0.1

This releases includes support for the nfacct extended iptables
accounting infrastructure.

See ChangeLog that comes attached to this email for more details.

You can download it from:

http://www.netfilter.org/projects/ulogd/downloads.html
ftp://ftp.netfilter.org/pub/ulogd/

Have fun!

--sdtB3X0nJg68CQEu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-ulogd-2.0.1.txt"

Eric Leblond (6):
      NFCT: fix crash in polling mode if used by two stacks
      nfacct: add variable to not zero counter after read
      pgsql schema: add nfacct table
      pgsql schema: fix timestamp default value
      pgsql: only disable key if it starts with underscore
      nfacct: add timestamp option

Michael Tremer (1):
      sqlite3: Add more logging if database initialization fails.

Pablo Neira Ayuso (9):
      src: add ULOGD_DTYPE_SUM for nfacct-based accounting
      output: XML: support for NFACCT input plugin
      output: XML: display time for NFACCT
      input: NFCT: fix compilation warning with gcc-4.7
      src: fix version that -V displays
      ulogd.conf: slightly expand documentation on zerocounter option for nfacct
      filter: IP2HBIN: fix compilation warning with gcc-4.7
      src: update copyright and authors information
      bump version to 2.0.1

Thomas Jarosch (1):
      ipfix: fix bracket imbalance if IPPROTO_SCTP is defined


--sdtB3X0nJg68CQEu--
