From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 00/12] be2net: patch set
Date: Fri, 19 Sep 2014 15:46:50 +0530
Message-ID: <1411121822-25842-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:52817 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752350AbaISKO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 06:14:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patches 1 and 2 fix sparse warnings (static declaration needed and endian
declaration needed) introduced by the earlier patch set.

Patches 3 and 4 add 20G/40G speed reporting via ethtool for the Skyhawk-R
chip.

Patches 5 to 12 fix various style issues and checkpatch warnings in the
driver such as:
	- removing unnecessary return statements in void routines
	- adding needed blank lines after a declaration block
	- deleting multiple blank lines
	- inserting a blank line after a function/struct definition
	- removing space after typecast
	- fixing multiple assignments on a single line
	- fixing alignment on a line wrap

Please consider applying this patch set to the net-next tree. Thanks!

Kalesh AP (10):
  be2net: fix a sparse warning in be_cmd_modify_eqd()
  be2net: add speed reporting for 40G/KR interface
  be2net: remove return statements for void functions
  be2net: add blank line after declarations
  be2net: remove multiple blank lines
  be2net: insert a blank line after function/struct//enum definitions
  be2net: remove unnecessary blank lines after an open brace
  be2net: remove space after typecasts
  be2net: remove multiple assignments on a single line
  be2net: fix alignment on line wrap

Suresh Reddy (1):
  be2net: fix sparse warnings in be_cmd_req_port_type{}

Vasundhara Volam (1):
  be2net: add speed reporting for 20G-KR interface
