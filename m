From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 0/5] RDS rds_iovec fixes
Date: Thu, 28 Oct 2010 18:40:54 -0700
Message-ID: <1288316459-4679-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:43944 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758108Ab0J2Bl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 21:41:57 -0400
Received: from acsinet15.oracle.com (acsinet15.oracle.com [141.146.126.227])
	by rcsinet10.oracle.com (Switch-3.4.2/Switch-3.4.2) with ESMTP id o9T1fti9030898
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 29 Oct 2010 01:41:57 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David and everyone,

This patchset includes Linus' rds_iovec overflow fix, as well as making
a copy of the rds_iovec array to prevent userspace from changing them after
we've checked them.

Please especially review patch 5. We go from 3 to 2 iovec copies, but it's not
trivial to go to one, due to some code that wants to preallocate space for SGs.
Until that code can be changed, patch 5 attempts to safely handle the scenario.

Thanks -- Regards -- Andy

