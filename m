From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 0/2] sunvnet: perf tracepoint hooks
Date: Tue,  2 Feb 2016 10:41:54 -0800
Message-ID: <cover.1454416592.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, sowmini.varadhan@oracle.com,
	david.stevens@oracle.com, aaron.young@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30397 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753251AbcBBSmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 13:42:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added some perf tracepoints to help track and debug sunvnet 
descriptor state at run-time.

Sowmini Varadhan (2):
  sunvnet: Add support for perf LDC event tracing
  sunvnet: perf tracepoint invocations to trace LDC state machine

 drivers/net/ethernet/sun/sunvnet.c |   24 ++++++-
 include/trace/events/sunvnet.h     |  139 ++++++++++++++++++++++++++++++++++++
 2 files changed, 161 insertions(+), 2 deletions(-)
 create mode 100644 include/trace/events/sunvnet.h
