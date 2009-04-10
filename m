From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH net-next 0/12] RDS: updates for net-next
Date: Thu,  9 Apr 2009 17:09:35 -0700
Message-ID: <1239322187-3764-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:53205 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754017AbZDJAJ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 20:09:58 -0400
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by acsinet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n3A0B8LY027007
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 10 Apr 2009 00:11:09 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, this is a series of noncritical rds updates for net-next.
Shortlog follows.

Regards -- Andy

Andy Grover (4):
      RDS: Correct some iw references in rdma_transport.c
      RDS: Fix ordering in a conditional
      RDS: Establish connection before parsing CMSGs
      RDS: use get_user_pages_fast()

Dan Carpenter (2):
      ERR_PTR() dereference in net/rds/iw.c
      ERR_PTR() dereference in net/rds/ib.c

Huang Weiyi (1):
      RDS: remove unused #include <version.h>

Kyle McMartin (1):
      MAINTAINERS: rds list is moderated

Steve Wise (3):
      RDS/IW+IB: Set recv ring low water mark to 1/2 full.
      RDS/IW+IB: Set the RDS_LL_SEND_FULL bit when we're throttled.
      RDS/IW+IB: Allow max credit advertise window.

Wei Yongjun (1):
      rds: use kmem_cache_zalloc instead of kmem_cache_alloc/memset



