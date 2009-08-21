From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH net-next 0/5] RDS: TCP transport support
Date: Fri, 21 Aug 2009 15:28:30 -0700
Message-ID: <1250893715-21939-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:24406 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755291AbZHUW2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2009 18:28:41 -0400
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by rgminet12.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n7LMSYnO016112
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 21 Aug 2009 22:28:35 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello netdev,

This patch series adds a TCP transport for RDS. Instead of requiring
an IB queue pair for communication between two nodes, it may instead 
tunnel traffic over a TCP connection. This makes RDS usable by
people without IB hardware, or in a VM.

In addition, this patchset modularizes RDS into an rds core module,
an rds_rdma module (for Infiniband and iWARP) and rds_tcp module. RDS
itself no longer has a dependency on IB (the rds_rdma module does).

This code has been tested and verified to work and perform acceptably, 
but has not yet had intensive performance analysis.

Thanks -- Regards -- Andy


